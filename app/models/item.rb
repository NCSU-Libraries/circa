class Item < ActiveRecord::Base

  # app/models/concerns/aspace_connect.rb
  include AspaceConnect
  # app/models/concerns/item_state_config.rb
  include ItemStateConfig
  # app/models/concerns/state_transition_support.rb
  include StateTransitionSupport
  # app/models/concerns/ref_integrity.rb
  include RefIntegrity
  # lib/modules/ncsu_catalog_utilities.rb
  include NcsuCatalogUtilities
  # app/models/concerns/ncsu_catalog.rb
  include NCSUCatalog
  # app/models/concerns/solr_doc.rb
  include SolrDoc

  belongs_to :permanent_location, class_name: "Location"
  belongs_to :current_location, class_name: "Location"
  has_many :item_orders
  has_many :orders, through: :item_orders do
    def open
      where(open: true)
    end
  end
  has_many :item_archivesspace_records
  has_one :item_catalog_record
  has_many :access_sessions do
    def active
      where(active: true)
    end
  end
  has_one :active_access_session, -> { where active: true }, class_name: 'AccessSession'
  has_many :access_users, through: :access_sessions

  attr_accessor :archivesspace_records


  validates :uri, uniqueness: true, unless: :digital_object


  before_create do
    if !self.current_location_id
      self.current_location_id = self.permanent_location_id
    end
  end


  # Retrieve ArchivesSpace API response corresponding to an ArchivalObject URI
  #   and create one or more Item records based on instances included in response
  # Because a single ArchivesSpace can represent materials in multiple containers,
  #   this method returns an array of Item objects
  def self.create_or_update_from_archivesspace(archivesspace_uri, options = { digital_object: nil } )
    items_attributes = []
    items = []
    data = aspace_api_get(archivesspace_uri, { resolve: ['linked_instances','resource', 'digital_object'] })

    if data
      attributes = {}

      if archivesspace_uri.match(/\/resources\//)
        attributes[:resource_uri] = data['uri']
        resource = data
      else
        attributes[:resource_uri] = data['resource']['ref']
        resource = data['resource']['_resolved']
      end
      attributes[:resource_title] = resource['title']
      attributes[:resource_identifier] = resource['id_0']


      get_physical_item_attributes = Proc.new do
        data['instances'].each do |i|
          item_attributes = attributes.clone
          # if i['container'] condition skips digital object instances
          if i['container']
            type = i['container']['type_1']
            indicator = i['container']['indicator_1']
            if !type.blank?
              item_attributes[:container] = type.gsub(/_/,' ')
              item_attributes[:uri] = attributes[:resource_uri] + "/#{type}"
              if !indicator.blank?
                item_attributes[:container] += " #{indicator}"
                item_attributes[:uri] += "/#{indicator}"
              end
            end

            item_attributes[:barcode] = i['container']['barcode_1']

            locations = i['container']['container_locations']

            add_location = Proc.new do |location_uri|
              location = Location.create_or_update_from_archivesspace(location_uri)
              item_attributes[:permanent_location_id] = location.id
            end

            if locations.length == 1
              add_location.call(locations.first['ref'])
            else
              locations.each do |l|
                if l['status'] == 'current'
                  add_location.call(l['ref'])
                end
              end
            end
            items_attributes << item_attributes
          end
        end
      end


      get_digitial_item_attributes = Proc.new do
        data['instances'].each do |i|
          item_attributes = attributes.clone
          if i['digital_object']
            item_attributes[:digital_object] = true
            item_attributes[:uri] = i['digital_object']['ref']
            item_attributes[:digital_object_title] = i['digital_object']['_resolved']['title']
            items_attributes << item_attributes
          end
        end
        if items_attributes.empty?
          item_attributes = attributes.clone
          item_attributes[:digital_object] = true
          item_attributes[:unprocessed] = true
          item_attributes[:uri] = archivesspace_uri
          items_attributes << item_attributes
        end
      end


      if options[:digital_object]
        get_digitial_item_attributes.call
      else
        get_physical_item_attributes.call
      end

    end

    items_attributes.each do |i|
      if !options[:digital_object] || options[:force_update]
        update_items = Item.where(uri: i[:uri])
      end

      if update_items && !update_items.empty?
        update_items.each do |item|
          item.update_attributes(i)
        end
      else
        i[:current_location_id] = i[:permanent_location_id]
        new_item = Item.create!(i)
        update_items = [new_item]
      end

      update_items.each do |item|
        ItemArchivesspaceRecord.find_or_create_by(item_id: item.id, archivesspace_uri: archivesspace_uri)

        # reload to ensure that ItemArchivesspaceRecord is included when items are returned to controller
        item.reload

        # Need to update the index here to make sure the 'source' attribute set correctly,
        # based on the existence of associated AS or catalog record,
        # which are not present when the item is created (and added to index after_save)
        item.update_index

        items << item
      end

    end

    # Deal with an edge case where an item previously
    #   marked as obsolete has been restored
    items.each do |i|
      i.update_columns(obsolete: nil)
    end

    !items.empty? ? items : nil
  end


  # Returns an array of all ArchivesSpace URIs associated with this item
  # (ie URIs used to add item to orders)
  def archivesspace_records
    item_archivesspace_records.map { |iar| iar.archivesspace_uri }
  end


  # Returns all open orders that include this item
  def open_orders
    orders.open
  end


  # Returns boolean
  def has_open_orders?
    open_orders.length > 0
  end


  # Searches orders associated with this item and returns next upcoming access date
  def next_scheduled_use_date
    next_date = nil

    open_orders.each do |o|
      if o.access_date_start
        next_date ||= o.access_date_start
        if o.access_date_start < next_date
          next_date = o.access_date_start
        end
      end
    end
    next_date
  end


  # Returns true if the item is associated with an active access_session
  def in_use?
    active_session = access_sessions.active.first
    !active_session.nil?
  end


  # Retruns all active access_sessions
  def active_access_session
    access_sessions.active.first
  end


  # Returns true if this item is associated with an open order that has been confirmed
  def has_confirmed_order?
    confirmed_order = false
    open_orders.each do |o|
      if o.confirmed
        confirmed_order = true
        break
      end
    end
    confirmed_order
  end


  # The logic here is that the order associated with the item's
  # last state transition is its active order
  def active_order_id
    last_transition ? last_transition.order_id : nil
  end


  def source
    if item_catalog_record
      'catalog'
    elsif !item_archivesspace_records.blank?
      'archivesspace'
    else
      'unknown'
    end
  end


  def event_history
    history = []

    # Get location per event (or where applicable?)
    event_attributes = lambda do |state_transition|
      attributes = {
        event: transition.metadata[:event].gsub(/_/, ' '),
        datetime: transition.created_at,
        order_id: transition.metadata[:order_id]
      }
      staff_user = User.where(id: transition.metadata[:user_id]).first
      if staff_user
        attributes[:staff_user] = user_attributes(staff_user)
      end
      attributes
    end

    state_transitions.each do |t|
      history << event_attributes.call(t)
    end

    history
  end


  def movement_history
    history = []

    # Get location per event (or where applicable?)
    event_attributes = lambda do |state_transition|
      attributes = {
        state_transition_id: state_transition.id,
        datetime: state_transition.created_at,
        order_id: state_transition.metadata[:order_id],
        user_id: state_transition.user_id
      }
      case state_transition.to_state.to_sym
      when :in_transit_to_temporary_location
        attributes[:location_id] = permanent_location_id
        attributes[:action] = 'depart'
      when :arrived_at_temporary_location
        attributes[:location_id] = state_transition.metadata[:location_id]
        attributes[:action] = 'arrive'
      when :returning_to_permanent_location
        attributes[:location_id] = state_transition.metadata[:location_id]
        attributes[:action] = 'depart'
      when :at_permanent_location
        attributes[:location_id] = permanent_location_id
        attributes[:action] = 'arrive'
      else
        # ignore other events in preparing movement history
        return nil
      end

      if attributes[:user_id]
        user = User.find_by(id: attributes[:user_id])
        if user
          attributes[:user] = user_attributes(user)
        end
      end

      if attributes[:location_id]
        location = Location.find_by(id: attributes[:location_id])
        if location
          attributes[:location] = location_attributes(location)
        end
      end

      return attributes
    end

    state_transitions.each do |t|
      attributes = event_attributes.call(t)
      if attributes
        history << event_attributes.call(t)
      end
    end

    history
  end


  def last_accessed
    if access_sessions.length > 0
      a = access_sessions.order(:start_datetime).last
      a.start_datetime
    end
  end


  # For items for which the ArchivesSpace top container no longer exists due to re-processing
  def mark_as_obsolete
    replacement_items = []

    item_orders.each do |io|
      return_items = io.update_archivesspace_item
      replacement_items += return_items
    end

    eligible_for_obsolete = !replacement_items.include?(self)
    puts eligible_for_obsolete ? "Item is eligible to be made obsolete" : "Item is NOT eligible to be made obsolete"

    if eligible_for_obsolete
      update_columns(current_location_id: nil, permanent_location_id: nil, obsolete: true)
      item_orders.each do |io|
        io.update_columns(archivesspace_uri: nil, active: false)
      end
      update_index
    else
      raise CircaExceptions::BadRequest,
        "The item could not be marked as obsolete because one or more of the ArchivesSpace URIs
        associated with it still return a record with container information matching that of the item."
    end
  end


  def digital_item_access_sessions
    items = Item.where(uri: uri)
    all_access_sessions = []
    items.each do |i|
      i.access_sessions.each { |a| all_access_sessions << a }
    end
    all_access_sessions
  end


  def active_order_ids
    ids = []
    item_orders.each do |io|
      if io.active && io.order.open
        ids << io.order_id
      end
    end
    ids
  end


  def has_active_access_session_for_order?(order_id)
    if active_access_session
      active_access_session.order_id == order_id
    else
      false
    end
  end


  def deactivate_for_order(order_id)
    if !has_active_access_session_for_order?(order_id)
      item_orders.where(order_id: order_id).each { |io| io.deactivate }
    end
  end


  def activate_for_order(order_id)
    item_orders.where(order_id: order_id).each { |io| io.activate }
  end


  def active_for_order?(order_id)
    item_orders.where(order_id: order_id, active: true).length > 0
  end


  def update_from_source
    case source
    when 'archivesspace'
      archivesspace_uris = []
      item_archivesspace_records.each { |iar| archivesspace_uris << iar.archivesspace_uri }
      archivesspace_uris.each do |uri|
        options = { digital_object: digital_object }
        options[:force_update] = digital_object ? true : nil
        Item.create_or_update_from_archivesspace(uri, options)
      end
    when 'catalog'
      if item_catalog_record
        Item.create_or_update_from_catalog(icr.catalog_record_id, icr.catalog_item_id)
      end
    end
  end


  private


  def user_attributes(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      display_name: user.display_name,
      email: user.email
    }.with_indifferent_access
  end


  def location_attributes(location)
    location.attributes.with_indifferent_access
  end


end
