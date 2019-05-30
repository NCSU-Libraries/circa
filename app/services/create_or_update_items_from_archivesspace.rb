class CreateOrUpdateItemsFromArchivesspace

  include AspaceUtilities

  def self.call(uri, options = { digital_object: nil })
    object = new(uri, options)
    object.call
  end

  def initialize(uri, options = { digital_object: nil })
    @uri = uri
    @options = options
  end

  def call
    @data = aspace_api_get(@uri, {
      resolve:
          ['linked_instances', 'resource', 'digital_object', 'top_container']
    })
    create_or_update_items
  end

  private

  def create_or_update_items
    response = OpenStruct.new
    @items_attributes = []
    @items = []

    @attributes = {}

    if @data
      add_resource_attributes

      if @options[:digital_object]
        add_digitial_item_attributes
      else
        add_physical_item_attributes
      end
    end

    process_items
    response.items = !@items.empty? ? @items : nil
    response
  end

  def add_resource_attributes
    if @data['uri'].match(/\/resources\//)
      @attributes[:resource_uri] = @data['uri']
      @resource = @data
    else
      @attributes[:resource_uri] = @data['resource']['ref']
      @resource = @data['resource']['_resolved']
    end
    @attributes[:resource_title] = @resource['title']
    @attributes[:resource_identifier] = @resource['id_0']
  end

  def container_from_top_container(top_container)
    container = nil
    type = top_container['type']
    indicator = top_container['indicator']
    if !type.blank?
      container = type.gsub(/_/,' ')
      if !indicator.blank?
        container += " #{indicator}"
      end
    end
    container
  end

  def get_location_attributes(top_container)
    atts = {}
    locations = top_container['container_locations']

    add_location = Proc.new do |location_uri|
      location = create_or_update_location(location_uri)
      atts[:permanent_location_id] = location.id
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
    atts
  end

  def create_or_update_location(location_uri)
    data = aspace_api_get(location_uri)
    location = Location.find_by(uri: location_uri)
    atts = {
      title: data['title'].strip,
      facility: data['building'].strip,
      source_id: Location.archivesspace_location_source_id
    }

    # dumb fix for NCSU that won't affect anybody else
    if atts[:facility] =~ /D\.\s*H\.\s*Hill/
      atts[:facility] = "D. H. Hill"
    end
    # END - dumb fix for NCSU that won't affect anybody else

    if location
      location.update_attributes(atts)
    else
      atts[:uri] = location_uri
      location = Location.create!(atts)
    end
    location
  end

  def add_physical_item_attributes
    @data['instances'].each do |i|
      item_attributes = @attributes.clone

      if i['sub_container'] && i['sub_container']['top_container'] &&
          i['sub_container']['top_container']['_resolved']

        top_container = i['sub_container']['top_container']['_resolved']
        item_attributes[:uri]  = i['sub_container']['top_container']['ref']
        item_attributes[:container] =
            container_from_top_container(top_container)
        item_attributes[:barcode] = top_container['barcode']

        location_attributes = get_location_attributes(top_container)
        item_attributes.merge!(location_attributes)

        @items_attributes << item_attributes
      end
    end
  end

  def add_digitial_item_attributes
    @data['instances'].each do |i|
      item_attributes = @attributes.clone
      if i['digital_object']
        item_attributes[:digital_object] = true
        item_attributes[:uri] = i['digital_object']['ref']
        item_attributes[:digital_object_title] =
            i['digital_object']['_resolved']['title']
        @items_attributes << item_attributes
      end
    end
    if @items_attributes.empty?
      item_attributes = @attributes.clone
      item_attributes[:digital_object] = true
      item_attributes[:unprocessed] = true
      item_attributes[:uri] = @data['uri']
      @items_attributes << item_attributes
    end
  end

  def process_items
    @items_attributes.each do |i|
      if !@options[:digital_object] || @options[:force_update]
        update_items = Item.where(uri: i[:uri])
      end

      if update_items && !update_items.empty?
        update_items.each do |item|
          if item.current_state == :at_permanent_location
            i[:current_location_id] = i[:permanent_location_id]
          end
          item.update_attributes(i)
        end
      else
        i[:current_location_id] = i[:permanent_location_id]
        new_item = Item.create!(i)
        update_items = [new_item]
      end

      update_items.each do |item|
        ItemArchivesspaceRecord.find_or_create_by(item_id: item.id,
            archivesspace_uri: @data['uri'])
        # reload to ensure that ItemArchivesspaceRecord is included when items
        #   are returned to controller
        item.reload
        # Need to update the index here to make sure the 'source' attribute
        #   is set correctly, based on the existence of associated AS or
        #   catalog record, which are not present when the item is created
        #   (and added to index after_save)
        item.update_index
        @items << item
      end
    end

    # Deal with an edge case where an item previously
    #   marked as obsolete has been restored
    @items.each do |i|
      i.update_columns(obsolete: nil)
    end
  end

end
