class ItemOrderSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :item_id, :archivesspace_uri, :user_id
end
