class OrderItemsSerializer < ActiveModel::Serializer
  attributes :id, :resource_title, :resource_identifier, :resource_uri,
  :container, :uri, :barcode, :created_at, :updated_at, :current_state, :available_events, :permitted_events, :states_events, :in_use?,
  :digital_object, :permanent_location, :current_location, :active_access_session, :source, :item_catalog_record, :open_orders,
  :active_order_ids, :available_events_per_order, :digital_object_title, :obsolete

  # belongs_to :permanent_location
  # belongs_to :current_location
  # has_one :active_access_session, serializer: AccessSessionSerializer


  def created_at
    object.created_at.strftime('%FT%T%:z')
  end


  def updated_at
    object.created_at.strftime('%FT%T%:z')
  end


  def available_events_per_order
    events = {}
    object.open_orders.each do |o|
      events[o.id] = object.available_events_for_order(o.id)
    end
    events
  end


  def active_access_session
    session = object.active_access_session
    if session
      response_hash = {
        start_datetime: session.start_datetime,
        end_datetime: session.end_datetime
      }
      session.users.each do |user|
        (response_hash[:users] ||= []) << {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          display_name: user.display_name
        }
      end
      response_hash
    end
  end


  def source
    object.source
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

end
