class Order < ApplicationRecord

  include OrderStateConfig
  include StateTransitionSupport
  include EnumerationUtilities
  include RefIntegrity
  include VersionsSupport
  include SolrDoc

  belongs_to :order_sub_type
  has_one :order_type, through: :order_sub_type
  has_one :order_fee, as: :record
  has_many :order_users, -> { order 'order_users.created_at desc' }, dependent: :destroy
  has_many :users, through: :order_users, source: :user
  has_many :order_assignments, dependent: :destroy
  has_many :assignees, through: :order_assignments, source: :user
  has_many :item_orders, dependent: :destroy
  has_many :items, through: :item_orders
  has_many :notes, as: :noted
  has_one :course_reserve
  has_many :digital_collections_orders
  has_one :order_fee, as: :record
  has_one :invoice
  has_many :access_sessions do
    def active
      where(active: true)
    end
  end
  belongs_to :temporary_location, class_name: 'Location', foreign_key: 'location_id'

  has_paper_trail meta: {
    association_data: :association_data
  }

  attr_reader :archivesspace_records


  # As a failsafe, we don't actually destroy orders
  # We mark them as deleted, add a 'deleted' event to versions, and destroy associations
  def destroy
    if deletable?
      self.paper_trail_event = 'delete'
      update_attributes(deleted: true, open: false)
      previous_users = users.clone
      previous_items = items.clone
      order_users.each { |ou| ou.destroy }
      order_assignments.each { |oa| oa.destroy }
      item_orders.each { |io| io.destroy }
      previous_users.each { |u| u.update_index }
      previous_items.each { |i| i.update_index }
      delete_from_index
    else
      false
    end
  end


  def order_type_id
    order_type.id
  end


  def reproduction_order?
    order_type.name == 'reproduction'
  end


  def self.first_datetime
    where('created_at is not null').order('created_at asc').limit(1).pluck('created_at')[0]
  end


  # Returns user indicated as 'primary' for this order
  def primary_user
    primary_order_user = order_users.where(primary: true).first || order_users.first
    primary_order_user ? primary_order_user.user : nil
  end


  def association_data
    data = {}
    data[:assignee_ids] = assignee_ids
    data[:user_ids] = user_ids
    data[:item_ids] = item_ids
    data
  end


  ## This method does not quite work because it wasn't spec'ed very well
  ## Should provide data for a user at the time of a specific version
  ##   but we need to pass either a version idex or timestamp to this method
  ##   and I'm not sure which to do because the method isn't actually used.

  def version_users
    if !self.paper_trail.live?
      v = self.version
      if v.association_data[:user_ids]
        v_users = []
        users = User.where("id IN (#{ v.association_data[:user_ids].join(',') })")
        users.each do |u|
          v_users << u.paper_trail.version_at(v.created_at)
        end
        v_users
      end
    else
      users
    end
  end


  ## This method does not quite work because it wasn't spec'ed very well
  ## Should provide assignees at the time of a specific version
  ##   but we need to pass either a version idex or timestamp to this method
  ##   and I'm not sure which to do because the method isn't actually used.

  def version_assignees
    if !self.paper_trail.live?
      v = self.version
      if v.association_data[:assignee_ids]
        v_assignees = []
        users = User.where("id IN (#{ v.association_data[:assignee_ids].join(',') })")
        users.each do |u|
          v_assignees << u.paper_trail.version_at(v.created_at)
        end
        v_assignees
      end
    else
      assignees
    end
  end


  # assigns order to user (in addition to existing assignees, if applicable)
  def assign_to(user_id)
    paper_trail.save_with_version
    order_assignments.create!(user_id: user_id)
  end


  # reassigns order to user (replacing existing assignments)
  def reassign_to(user_id)
    paper_trail.save_with_version
    order_assignments.each { |a| a.destroy }
    order_assignments.create!(user_id: user_id)
  end


  def archivesspace_records
    uris = []
    item_orders.each do |oar|
      uris += oar.archivesspace_uri
    end
    uris.uniq
  end


  def catalog_records
    ids = []
    item_orders.each do |oar|
      if oar.item.item_catalog_record
        ids << oar.item.item_catalog_record.catalog_record_id
      end
    end
    ids.uniq
  end


  def catalog_items
    ids = []
    item_orders.each do |oar|
      if oar.item.item_catalog_record
        ids << oar.item.item_catalog_record.catalog_item_id
      end
    end
    ids.uniq
  end


  def create_or_update_course_reserve(attributes)
    if course_reserve
      course_reserve.update_attributes(attributes)
    else

      # permit protected attributes passed from controller via nested object in request data
      attributes.permit!

      create_course_reserve!(attributes)
    end
  end


  def includes_item?(item)
    item_orders.exists?(item_id: item.id)
  end


  def num_items
    items.length
  end


  def add_item(item, archivesspace_uri = nil)
    item_order = item_orders.find_or_create_by(item_id: item.id)
    if archivesspace_uri
      item_order.add_archivesspace_uri(archivesspace_uri)
    end
    item_order
  end


  def active?
    access_sessions.active.length > 0
  end


  def close
    update_attributes(open: false)
  end


  def closed?
    !open
  end


  def reopen
    update_attributes(open: true)
  end


  def confirm
    update_attributes(confirmed: true)
  end


  def clone_orders
    orders = []
    Order.where(cloned_order_id: id).each do |o|
      orders << { id: o.id, order_sub_type: o.order_sub_type }
    end
    !orders.empty? ? orders : nil
  end


  # Returns true if the order can be destroyed,
  #   which is only permitted if the order has not yet reached the 'fulfilled' state
  #   and if the items on the order have not been transferred
  def deletable?
    deletable = true
    if state_reached?(:fulfilled)
      deletable = false
    else
      items.each do |i|
        if !i.digital_object
          transferred = i.state_reached?(:in_transit_to_temporary_location)
          if transferred && i.active_order_id == id
            deletable = false
            break
          end
        end
      end
    end
    deletable
  end


  # Returns all state transitions (sorted by date) for this order and its included items
  # Each transition includes information about user responsible
  def history
    transition_data = lambda do |state_transition|
      data = {}
      [ :record_id, :record_type, :to_state, :from_state, :created_at ].each do |attr|
        data[attr] = state_transition[attr]
      end
      if state_transition.user_id
        user = User.find_by(id: state_transition.user_id)
        if user
          data[:user] = {}
          [ :id, :email, :last_name, :first_name, :display_name ].each { |a| data[:user][a] = user[a] }
        end
      end
      if state_transition.record_type == 'Item'
        item = Item.find_by(id: state_transition.record_id)
        if item
          data[:item] = {}
          [ :id, :resource_title, :resource_identifier, :container ].each { |a| data[:item][a] = item[a] }
        end
      end
      return data
    end

    h = state_transitions.map { |st| transition_data.call(st) }
    item_transitions = StateTransition.where(record_type: 'Item', order_id: self.id)
    h += item_transitions.map { |st| transition_data.call(st) }
    h.sort! { |x,y| x[:created_at] <=> y[:created_at] }
    h
  end


  def item_ids
    items.map { |i| i.id }
  end


  # Returns true if order includes items associated with digital objects
  def has_digital_items?
    has_digital_items = false
    items.each do |i|
      if i.digital_object
        has_digital_items = true
        break
      end
    end
    has_digital_items
  end


  def order_fees
    fees_for_collection = lambda do |collection|
      collection.map { |x| x.order_fee ? x.order_fee : nil }
    end
    fees = [item_orders.to_a, digital_collections_orders.to_a].flat_map { |x| fees_for_collection.(x) }
    fees.delete_if { |f| f.nil? }
    if self.order_fee
      fees << self.order_fee
    end
    fees
  end


  def has_fees?
    !order_fees.empty? ? true : false;
  end


  def order_fees_total
    order_fees.reduce(0) { |sum, fee| sum + fee.total }
  end


  def cleanup_reproduction_associations
    if order_type.name != 'reproduction'
      order_fees.each { |of| of.destroy! }
      digital_collections_orders.each { |dio| dio.destroy! }
      item_orders.each do |io|
        if io.reproduction_spec
          io.reproduction_spec.destroy!
        end
      end
    end
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include OrderCustom
  rescue
  end

end
