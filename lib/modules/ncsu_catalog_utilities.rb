module NcsuCatalogUtilities

  def self.included receiver
    receiver.extend self
  end


  def catalog_item_data_from_request_item(request_item)
    item_data = ActiveSupport::HashWithIndifferentAccess.new
    keys = [ 'library', 'barcode', 'displayLibrary', 'locationCode',
      'location', 'displayLocation', 'callNumber', 'format' ]
    keys.each do |k|
      item_data[k] = request_item[k]
    end
    item_data
  end


  def catalog_request_item_from_record(record, catalog_item_id)
    request_item = nil
    items = record[:requestOptions][:requestItems]
    items.each do |item|
      if item[:barcode] == catalog_item_id
        request_item = item
        break
      end
    end
    request_item
  end


  def catalog_id_from_url(string)
    catalog_id = string.gsub(/^(https?\:\/\/)?catalog\.lib\.ncsu\.edu\/record\//,'')
    catalog_id.gsub(/\..*$/,'')
  end

end
