require 'active_support/concern'

module NCSUCatalog
  extend ActiveSupport::Concern

  included do

    def self.create_or_update_from_catalog(catalog_record_id, catalog_item_id)
      connection = NcsuCatalogApiClient::Connection.new
      record = connection.get_record_by_id(catalog_record_id)
      title = record[:record][:title]
      uri = "/catalog_item/#{catalog_record_id}/#{catalog_item_id}"
      request_item = catalog_request_item_from_record(record, catalog_item_id)
      if request_item
        catalog_item_data = catalog_item_data_from_request_item(request_item)

        resource_id = catalog_item_data['callNumber']
        barcode = catalog_item_data['barcode']
        location = Location.create_or_update_from_catalog_item(request_item)
        item_attributes = {
          resource_title: title,
          resource_identifier: resource_id,
          permanent_location_id: location.id,
          barcode: barcode
        }

        item = Item.find_by(uri: uri)

        if item
          item.update_attributes(item_attributes)
        else
          item = Item.create!(item_attributes.merge( { uri: uri } ))
        end

        if !item.item_catalog_record
          item.create_item_catalog_record!(
            catalog_record_id: catalog_record_id,
            catalog_item_id: catalog_item_id,
            catalog_item_data: catalog_item_data.to_hash
          )
        else
          item.item_catalog_record.update_attributes(catalog_item_data: catalog_item_data.to_hash)
        end

        # reload to ensure that ItemCatalogRecord is included when items are returned to controller
        item.reload

        # Need to update the index here to make sure the 'source' attribute set correctly,
        # based on the existence of associated AS or catalog record,
        # which are not present when the item is created (and added to index after_save)
        # consider using atomic updates if performance becomes an issue - may require schema changes
        item.update_index
      end
      item
    end


    def ncsu_facility
      facility = nil
      case source
      when 'ArchivesSpace'
        facility = title.gsub(/\[[^\]]*\]/,'').strip
      when 'Catalog'
        if catalog_item_data
          case catalog_item_data[:locationCode]
          when catalog_item_data[:locationCode].match(/^SPECCOLL/)
            facility = 'D.H. Hill'
          when catalog_item_data[:locationCode].match(/^BOOKBOT/)
            facility = 'bookBot'
          end
        end
      when 'Circa'

      end
      facility
    end

  end

end
