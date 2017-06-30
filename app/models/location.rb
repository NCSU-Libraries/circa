class Location < ActiveRecord::Base

  include AspaceConnect
  include EnumerationUtilities
  include NcsuCatalogUtilities
  include RefIntegrity
  include SolrDoc

  serialize(:catalog_item_data)

  has_many :permanent_items, class_name: "Item", foreign_key: 'permanent_location_id'
  has_many :current_items, class_name: "Item", foreign_key: 'current_location_id'
  has_many :orders

  after_create do
    if !self.uri
      self.update_attributes(uri: "/circa_locations/#{ self.id }")
    end
  end


  before_save do
    if self.default
      Location.where(default: true).where.not(id: self.id).find_each { |l| l.update_attributes(default: false) }
    end
  end


  def self.create_or_update_from_archivesspace(archivesspace_uri)
    data = aspace_api_get(archivesspace_uri)
    location = Location.find_by(uri: archivesspace_uri)
    if location
      location.update_from_archivesspace(data)
    else
      location = Location.create(uri: archivesspace_uri, title: data['title'].strip, facility: data['building'].strip, source_id: archivesspace_location_source_id)
    end
    location
  end


  def self.facilities
    records = Location.find_by_sql('SELECT DISTINCT facility FROM locations WHERE facility IS NOT NULL')
    records.map { |l| l.facility }
  end


  def update_from_archivesspace(data = nil)
    data ||= aspace_api_get(uri)
    if data
      update_attributes(title: data['title'].strip, facility: data['building'].strip, source_id: Location.archivesspace_location_source_id)
    end
  end



  # NCSU-SPECIFIC - move to custom module
  def self.create_or_update_from_catalog_item(request_item)
    uri = uri_from_catalog_item_request_url(request_item['itemRequestURL'])
    catalog_item_id = request_item['barcode']
    catalog_item_data = catalog_item_data_from_request_item(request_item)
    title = location_title_from_catalog_request_item(request_item)
    location = Location.find_by(uri: uri)
    source_id = Location.catalog_location_source_id

    # Sirsi Library       Sirsi Home Location      Physical Location
    # SPECCOLL            AUCTIONCAT               Satellite
    # SPECCOLL            FACULTYPUBS              Satellite
    # SPECCOLL            OVERSIZE2                Satellite
    # SPECCOLL            SATELLITE                Satellite
    # SPECCOLL            SAT-OV                   Satellite
    # SPECCOLL            SAT-OV2                  Satellite
    # SPECCOLL            FACPUBS-RR               Hill
    # SPECCOLL            METCALF                  Hill
    # SPECCOLL            OFF-SPEC                 Hill
    # SPECCOLL            OVERSIZE                 Hill
    # SPECCOLL            REF                      Hill
    # SPECCOLL            REF-ATLAS                Hill
    # SPECCOLL            REF-OVER                 Hill
    # SPECCOLL            REF-OVER2                Hill
    # SPECCOLL            SMALLBOOK                Hill
    # SPECCOLL            STACKS                   Hill
    # BOOKBOT             SPEC-D                   bookBot
    # BOOKBOTL            SPEC-OD                  bookBot

    get_facility = lambda do |location_code|
      facility = nil
      satellite_match = [ 'AUCTIONCAT', 'FACULTYPUBS', 'FACULTYPUB', 'OVERSIZE2', 'SATELLITE', 'SAT-OV', 'SAT-OV2' ]
      hill_match = [ 'FACPUBS-RR', 'METCALF', 'OFF-SPEC', 'OVERSIZE', 'REF',
        'REF-ATLAS', 'REF-OVER', 'REF-OVER2', 'SMALLBOOK', 'STACKS', 'SPECCOLL-SPEC', 'MICROFORMS']
      if location_code.match('BOOKBOT')
        facility = 'bookBot'
      end
      if facility
        return facility
      else
        satellite_match.each do |m|
          if location_code.match(m)
            facility = 'Satellite'
            break
          end
        end
        if facility
          return facility
        else
          hill_match.each do |m|
            if location_code.match(m)
              facility = 'D.H. Hill'
              break
            end
          end
        end
      end

      if facility
        facility.strip!
      end

      return facility
    end

    facility = get_facility.call(request_item['locationCode'])

    if !location
      location = Location.create(title: title, uri: uri, catalog_item_id: catalog_item_id, catalog_item_data: catalog_item_data, facility: facility, source_id: source_id)
    else
      location.update_attributes(title: title, catalog_item_data: catalog_item_data, facility: facility, source_id: source_id)
    end
    location
  end



  def self.uri_from_catalog_item_request_url(item_request_url)
    item_request_url.gsub(/request/, 'catalog_item_location')
  end


  def self.circa_location_source_id
    get_enumeration_value_id('circa', 'location_source')
  end


  def self.archivesspace_location_source_id
    get_enumeration_value_id('archivesspace', 'location_source')
  end


  def self.catalog_location_source_id
    get_enumeration_value_id('catalog', 'location_source')
  end


  def self.location_title_from_catalog_request_item(request_item)
    title = ''
    library = request_item['displayLibrary']
    location1 = request_item['displayLocation']
    location2 = request_item['location']
    title_location = nil

    if !location1.blank? && !location2.blank?
      title_location = "#{location1}, #{location2}"
    elsif !location1.blank?
      title_location = location1
    elsif !location2.blank?
      title_location = location2
    end

    if !library.blank?
      title += library
      if title_location
        title += ", #{title_location}"
      end
    elsif title_location
      title += title_location
    end

    return !title.blank? ? title : 'unknown'
  end


  def source
    get_enumeration_value(source_id)
  end


end
