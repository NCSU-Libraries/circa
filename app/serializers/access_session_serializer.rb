class AccessSessionSerializer < ActiveModel::Serializer
  attributes :id, :start_datetime, :end_datetime, :order_id, :location, :users

  def location
    object.order.temporary_location
  end
end
