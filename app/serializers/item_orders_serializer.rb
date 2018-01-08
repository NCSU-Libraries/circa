class ItemOrdersSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :item_id, :archivesspace_uri, :user_id, :item, :order_fee, :reproduction_spec

  def order_fee
    if object.order_fee
      atts = object.order_fee.attributes
      atts['per_unit_fee'] = atts['per_unit_fee'].to_f if atts['per_unit_fee']
      atts['per_order_fee'] = atts['per_order_fee'].to_f if atts['per_order_fee']
      atts['unit_fee_options'] = unit_fee_options
      atts
    end
  end


  def unit_fee_options
    options = []
    reproduction_format = object.reproduction_spec.reproduction_format

    if reproduction_format.default_unit_fee
      options << { name: 'default', value: reproduction_format.default_unit_fee }
    end

    if (reproduction_format.default_unit_fee_internal && reproduction_format.default_unit_fee_external)
      options << { name: 'default_internal', value: reproduction_format.default_unit_fee_internal }
      options << { name: 'default_external', value: reproduction_format.default_unit_fee_external }
    end

    options
  end


  def reproduction_spec
    if object.reproduction_spec
      atts = object.reproduction_spec.attributes
      atts['reproduction_format'] = object.reproduction_spec.reproduction_format
      atts
    end
  end


  def item
    i = object.item
    atts = i.attributes
    atts['created_at'] = i.created_at.strftime('%FT%T%:z')
    atts['updated_at'] = i.updated_at.strftime('%FT%T%:z')
    atts['current_state'] = i.current_state
    atts['available_events'] = i.available_events
    atts['permitted_events'] = i.permitted_events
    atts['states_events'] = i.states_events
    atts['in_use?'] = i.in_use?
    atts['digital_object'] = i.digital_object
    atts['permanent_location'] = i.permanent_location
    atts['current_location'] = i.current_location
    atts['active_access_session'] = active_access_session
    atts['source'] = i.source
    atts['item_catalog_record'] = i.item_catalog_record
    atts['open_orders'] = open_orders
    atts['active_order_ids'] = i.active_order_ids
    atts['available_events_per_order'] = available_events_per_order
    atts['digital_object_title'] = i.digital_object_title
    atts['obsolete'] = i.obsolete
    atts
  end


  def active_access_session
    session = object.item.active_access_session
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


  def open_orders
    orders = []
    object.item.open_orders.each do |o|
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


  def available_events_per_order
    events = {}
    object.item.orders.each do |o|
      if o.open || o.reproduction_order?
        events[o.id] = object.item.available_events_for_order(o.id)
      end
    end
    events
  end

end
