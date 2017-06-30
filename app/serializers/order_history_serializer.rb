class OrderHistorySerializer < ActiveModel::Serializer
  attributes :id, :access_date_start, :access_date_end, :order_type_id, :confirmed, :open, :created_at, :updated_at, :history

  belongs_to :order_type
  belongs_to :order_sub_type
end
