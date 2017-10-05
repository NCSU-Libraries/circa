class OrderSubTypeSerializer < ActiveModel::Serializer

  attributes :id, :name, :label, :order_type_id, :default_location_id, :order_type, :default_location

end
