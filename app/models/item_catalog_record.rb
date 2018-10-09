class ItemCatalogRecord < ApplicationRecord

  belongs_to :item
  serialize(:catalog_item_data)


  def call_number
    catalog_item_data['callNumber']
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include ItemCatalogRecordCustom
  rescue
  end


end
