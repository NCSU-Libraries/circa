class ItemCatalogRecord < ActiveRecord::Base

  belongs_to :item
  serialize(:catalog_item_data)

  def call_number
    catalog_item_data['callNumber']
  end
end
