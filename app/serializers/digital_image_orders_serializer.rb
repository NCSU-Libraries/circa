class DigitalImageOrdersSerializer < ActiveModel::Serializer
  attributes :order_id, :image_id, :detail, :label, :display_uri, :manifest_uri, :requested_images, :order_fee
end
