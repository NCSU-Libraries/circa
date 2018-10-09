class Location < ApplicationRecord

  include AspaceConnect
  include EnumerationUtilities
  include RefIntegrity
  include SolrDoc

  serialize(:catalog_item_data)

  has_many :permanent_items, class_name: "Item", foreign_key: 'permanent_location_id'
  has_many :current_items, class_name: "Item", foreign_key: 'current_location_id'
  has_many :orders
  has_many :order_sub_types, foreign_key: 'default_location_id'

  after_create do
    if !self.uri
      self.update_attributes(uri: "/circa_locations/#{ self.id }")
    end
  end


  def self.facilities
    records = Location.find_by_sql('SELECT DISTINCT facility FROM locations WHERE facility IS NOT NULL')
    records.map { |l| l.facility }
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


  def source
    get_enumeration_value(source_id)
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include LocationCustom
  rescue
  end

end
