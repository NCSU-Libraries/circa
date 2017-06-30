class UserOrdersSerializer < ActiveModel::Serializer
  attributes :id, :access_date_start, :access_date_end, :created_at, :updated_at, :current_state, :available_events, :num_items, :open
  belongs_to :temporary_location

  def num_items
    object.items.length
  end

end
