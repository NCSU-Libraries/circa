class OrderListSerializer < ActiveModel::Serializer
  attributes :id, :access_date_start, :access_date_end, :invoice_date,
      :created_at, :updated_at, :current_state, :available_events, :num_items,
      :open, :num_items_ready, :created_by_user, :has_fees

  belongs_to :order_type
  belongs_to :order_sub_type
  belongs_to :temporary_location
  has_many :users
  has_many :assignees

  def num_items
    object.items.length
  end

end
