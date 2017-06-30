class ItemHistorySerializer < ActiveModel::Serializer
  attributes :id, :resource_title, :resource_identifier, :resource_uri,
  :container, :uri, :created_at, :updated_at, :open_orders,
  :current_state, :in_use?, :movement_history
  belongs_to :permanent_location
  belongs_to :current_location
  has_many :orders, serializer: OrderListSerializer
  has_many :access_sessions
end
