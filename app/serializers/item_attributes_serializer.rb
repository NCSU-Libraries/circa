class ItemAttributesSerializer < ActiveModel::Serializer
  attributes :id, :resource_title, :resource_identifier, :resource_uri,
  :container, :obsolete, :uri, :created_at, :updated_at
end
