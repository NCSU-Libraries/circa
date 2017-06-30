class ItemListSerializer < ActiveModel::Serializer
  attributes :id, :resource_title, :resource_identifier, :resource_uri,
  :container, :uri, :barcode, :obsolete, :created_at, :updated_at,
  :current_state, :available_events, :permitted_events, :source
  belongs_to :permanent_location
  belongs_to :current_location
  has_one :item_catalog_record
end
