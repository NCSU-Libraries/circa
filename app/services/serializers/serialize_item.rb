class SerializeItem < SerializeRecord


  private


  def serialize
    @response = { item: {} }
    add_attributes
    add_associations
    @response
  end


  def add_attributes
    attributes = [
      :id, :resource_title, :resource_identifier, :resource_uri,
      :container, :uri, :digital_object, :unprocessed, :barcode, :obsolete,
      :created_at, :updated_at, :active_order_ids, :current_state, :in_use,
      :last_accessed, :source, :has_modification_history,
      :digital_object, :digital_object_title,
      :available_events, :permitted_events, :states_events,
      :available_events_per_order
    ]
    attributes.each do |a|
      case a
      when :created_at, :updated_at
        value = @record.send(a)
        value = format_datetime_value(value)
      when :has_modification_history
        value = @record.versions.length > 0
      when :in_use
        value = @record.in_use?
      when :available_events_per_order
        value = available_events_per_order
      else
        value = @record.send(a)
      end
      @response[:item][a] = value
    end
  end


  # :open_orders, :access_sessions, :active_access_session, :item_catalog_record
  # :open_orders
  def add_associations
    skip_associations = @options[:skip_associations] || []
    associations = [
      :permanent_location, :current_location, :active_access_session,
      :item_catalog_record, :orders, :open_orders, :active_orders, :access_sessions
    ]
    associations.each do |a|
      if !skip_associations.include?(a)
        case a
        when :permanent_location, :current_location
          location = @record.send(a)
          if location

            serialized_loc = SerializeRecord.call(location)

            @response[:item][a] = serialized_loc[:location]
          end
        when :access_sessions
          sessions = []
          if @record.digital_object
            all_sessions = @record.digital_item_access_sessions
          else
            all_sessions = @record.access_sessions
          end
          all_sessions.each do |as|
            session = as.attributes
            session[:location] = as.order.temporary_location
            session[:users] = as.users
            sessions << session
          end
          @response[:item][a] = sessions
        when :active_access_session
          access_session = @record.active_access_session
          if access_session
            @response[:item][a] = serialize_access_session(access_session)
          end
        when :item_catalog_record
          item_catalog_record = @record.item_catalog_record
          if item_catalog_record
            @response[:item][a] = serialize_attributes(item_catalog_record)
          end
        when :orders, :open_orders, :active_orders
          orders = @record.send(a)
          if orders
            @response[:item][a] = serialize_orders(orders)
          end
        end
      end
    end
  end


  def serialize_orders(orders)
    serialized_orders ||= []
    orders.each do |o|
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
      serialized_orders << order
    end
    serialized_orders
  end


  def available_events_per_order
    events = {}
    @record.orders.each do |o|
      if o.open || o.reproduction_order?
        events[o.id] = @record.available_events_for_order(o.id)
      end
    end
    events
  end


  def serialize_access_session(access_session)
    serialize_session_user = lambda do |user|
      return {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        display_name: user.display_name
      }
    end

    if access_session
      start_datetime = access_session.start_datetime
      end_datetime = access_session.end_datetime
      serialized = {
        start_datetime: format_datetime_value(start_datetime),
        end_datetime: format_datetime_value(end_datetime)
      }
      serialized[:users] = access_session.users.map { |u| serialize_session_user.(u) }
      serialized
    else
      nil
    end
  end


end
