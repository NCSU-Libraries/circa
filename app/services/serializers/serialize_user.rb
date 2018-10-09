class SerializeUser < SerializeRecord


  private


  def serialize
    @response = { user: {} }
    add_attributes
    add_associations
    @response
  end


  def add_attributes
    atts = [
      :id, :email, :current_sign_in_at, :last_sign_in_at, :created_at,
      :updated_at, :unity_id, :position, :affiliation, :first_name, :last_name,
      :display_name, :address1, :address2, :city, :state, :zip, :country,
      :phone, :agreement_confirmed, :researcher_type, :researcher_type_id,
      :user_role_id, :role, :is_admin, :assignable_roles,
      :has_active_access_session, :inactive
    ]

    atts.each do |a|
      case a
      when :current_sign_in_at, :last_sign_in_at, :created_at, :updated_at
        value = @record.send(a)
        value = format_datetime_value(value)
      when :agreement_confirmed
        value = @record.agreement_confirmed_at ? true : false
      when :assignable_roles
        value = @record.assignable_roles.map { |ar| {
          id: ar.id, name: ar.name, level: ar.level, users_count: ar.users.length
        }}
      when :has_active_access_session
        value = @record.has_active_access_session?
      else
        value = @record.send(a)
      end

      @response[:user][a] = value if value
    end
  end


  def add_associations
    skip_associations = @options[:skip_associations] || []
    associations = [
      :user_role, :orders, :notes
    ]
    associations.each do |a|
      if !skip_associations.include?(a)
        case a
        when :user_role
          value = serialize_attributes(@record.user_role)
        when :orders
          value = @record.orders.map { |o| serialize_order(o) }
        else
          associated_records = @record.send(a)
          value = associated_records.map { |aa| serialize_attributes(aa) }
        end
        @response[:user][a] = value
      end
    end
  end


  def serialize_order(order)
    serialized = {}
    atts = [
      :id, :access_date_start, :access_date_end, :created_at, :updated_at,
      :current_state, :available_events, :num_items, :num_items_ready, :open
    ]
    atts.each do |a|
      case a
      when :access_date_start, :access_date_end, :created_at, :updated_at
        value = order.send(a)
        value = format_datetime_value(value)
      when :num_items
        value = order.items.length
      else
        value = order.send(a)
      end
      serialized[a] = value
    end

    serialized[:order_type] = serialize_attributes(order.order_type)

    serialized[:order_sub_type] = serialize_attributes(order.order_sub_type)

    serialized[:assignees] = order.assignees.map { |u| serialize_attributes(u) }

    serialized[:resource_ids] = order.items.map { |i| i.resource_identifier }.uniq

    if order.temporary_location
      serialized_loc = SerializeRecord.call(order.temporary_location)
      serialized[:temporary_location] = serialized_loc[:location]
    end
    serialized
  end


end
