class DigitalImageOrdersSerializer < ActiveModel::Serializer
  attributes :order_id, :resource_identifier, :detail, :resource_title, :display_uri, :manifest_uri, :requested_images, :requested_images_detail, :order_fee

  def order_fee
    if object.order_fee
      atts = object.order_fee.attributes
      atts['per_unit_fee'] = atts['per_unit_fee'].to_f
      atts['per_order_fee'] = atts['per_order_fee'].to_f
      atts
    end
  end

end
