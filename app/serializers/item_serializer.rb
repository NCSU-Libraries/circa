class ItemSerializer < ActiveModel::Serializer
  attributes :id, :resource_title, :resource_identifier, :resource_uri,
  :container, :uri, :digital_object, :unprocessed, :barcode, :obsolete,
  :created_at, :updated_at, :open_orders, :active_order_id, :current_state,
  :available_events, :permitted_events, :in_use?, :source, :last_accessed,
  :digital_object_title, :access_sessions

  def created_at
    object.created_at.strftime('%FT%T%:z')
  end


  def updated_at
    object.created_at.strftime('%FT%T%:z')
  end


  def open_orders
    orders = []
    object.open_orders.each do |o|
      order = o.attributes.with_indifferent_access
      order[:order_type] = o.order_type
      order[:users] = o.users.map { |u|
        {
          id: u.id,
          last_name: u.last_name,
          first_name: u.first_name,
          display_name: u.display_name,
          email: u.email
        }
      }
      orders << order
    end
    orders
  end


  def access_sessions
    sessions = []
    if object.digital_object
      all_sessions = object.digital_item_access_sessions
    else
      all_sessions = object.access_sessions
    end
    all_sessions.each do |as|
      session = as.attributes
      session[:location] = as.order.temporary_location
      session[:users] = as.users
      sessions << session
    end
    sessions
  end


  belongs_to :permanent_location
  belongs_to :current_location
  has_many :orders, serializer: OrderListSerializer
  has_one :active_access_session

  has_one :item_catalog_record
end
