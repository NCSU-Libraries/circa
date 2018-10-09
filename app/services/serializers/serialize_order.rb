class SerializeOrder < SerializeRecord


  private


  def serialize
    @order = @record
    @response = { order: {} }
    add_attributes
    if @options[:include_associations]
      add_associations
    end
    @response
  end


  # Adds both native attributes and values generated from instance methods
  def add_attributes
    atts = [
      :id, :access_date_start, :access_date_end, :order_type_id,
      :order_sub_type_id, :confirmed, :open, :location_id, :created_at, :updated_at,
      :cloned_order_id, :archivesspace_records, :catalog_records,
      :catalog_items, :order_fee, :current_state, :permitted_events,
      :available_events, :states_events, :num_items, :primary_user_id,
      :primary_user_id, :num_items_ready, :created_by_user, :deletable,
      :item_ids_in_use, :has_fees, :clone_orders, :reproduction_order?
    ]
    atts.each do |a|
      case a
      when :created_at, :updated_at
        value = @record.send(a)
        value = format_datetime_value(value)
      when :num_items
        value = @record.items.length
      when :primary_user_id
        primary_user = @record.primary_user
        value = primary_user ? primary_user.id : nil
      when :deletable
        value = @record.deletable?
      when :has_fees
        value = @record.has_fees?
      when :item_ids_in_use
        value = @record.access_sessions.active.map { |s| s.item_id }
      else
        value = @record.send(a)
      end
      @response[:order][a] = value if value
    end
  end


  def add_associations
    skip_associations = @options[:skip_associations] || []

    to_one_associations = [ :order_type, :order_sub_type, :temporary_location,
        :course_reserve, :order_fee, :invoice ]

    to_one_associations.each do |a|
      if !skip_associations.include?(a)
        association = @record.send(a)
        if association
          case a
          when :order_fee
            @response[:order][:order_fee] = serialize_order_fee(association)
          when :temporary_location
            serialized_loc = SerializeRecord.call(association)
            @response[:order][:temporary_location] = serialized_loc[:location]
          else
            @response[:order][a] = serialize_attributes(association)
          end
        end
      end
    end

    to_many_associations = [
      :item_orders, :digital_collections_orders, :users, :assignees, :notes
    ]

    to_many_associations.each do |a|
      associations = @record.send(a)
      case a
      when :item_orders
        records = associations.map { |aa| serialize_item_order(aa) }
      when :users, :assignees
        records = associations.map { |aa| serialize_order_user(aa) }
      when :digital_collections_orders
        records = associations.map { |aa| serialize_digital_collections_order(aa) }
      else
        records = associations.map { |aa| serialize_attributes(aa) }
      end
      @response[:order][a] = records
    end
  end


  def serialize_order_user(user)
    serialized = SerializeUser.call(user, skip_associations: [:orders])
    order_user = OrderUser.where(order_id: @record.id, user_id: user.id).first
    if order_user
      serialized[:user][:primary] = order_user.primary
      serialized[:user][:remote] = order_user.remote
    end
    serialized[:user]
  end


  def serialize_order_fee(order_fee)
    serialized = serialize_attributes(order_fee)
    if serialized[:per_unit_fee]
      serialized[:per_unit_fee] = serialized[:per_unit_fee].to_f
    end
    if serialized[:per_order_fee]
      serialized[:per_order_fee] = serialized[:per_order_fee].to_f
    end
    serialized
  end


  def unit_fee_options(item_order)
    options = []
    reproduction_format = item_order.reproduction_spec.reproduction_format

    if reproduction_format.default_unit_fee
      options << {
        name: 'default', value: reproduction_format.default_unit_fee
      }
    end

    if (reproduction_format.default_unit_fee_internal && reproduction_format.default_unit_fee_external)
      options << {
        name: 'default_internal',
        value: reproduction_format.default_unit_fee_internal
      }
      options << {
        name: 'default_external',
        value: reproduction_format.default_unit_fee_external
      }
    end

    options
  end


  def serialize_item_order(item_order)
    serialized = {}
    atts = [
      :id, :order_id, :item_id, :archivesspace_uri, :user_id, :item,
      :order_fee, :reproduction_spec, :workflow_complete, :active
    ]
    item = item_order.item
    atts.each do |a|
      case a
      when :order_fee
        order_fee = item_order.order_fee
        if order_fee
          serialized[:order_fee] = serialize_order_fee(order_fee)
          serialized[:order_fee][:unit_fee_options] = unit_fee_options(item_order)
        end
      when :reproduction_spec
        reproduction_spec = item_order.reproduction_spec
        if reproduction_spec
          serialized[:reproduction_spec] = reproduction_spec.attributes
          serialized[:reproduction_spec][:reproduction_format] =
              reproduction_spec.reproduction_format.attributes
        end
      when :item
        serialized[:item] = SerializeItem.call(item, skip_associations: [:orders] )[:item]
      when :workflow_complete
        serialized[:workflow_complete] = item.workflow_complete_for_order(@order.id)
      else
        serialized[a] = item_order.send(a)
      end
    end
    serialized
  end


  def serialize_digital_collections_order(digital_collections_order)
    serialized = {}
    atts = [
      :order_id, :resource_identifier, :detail, :resource_title, :display_uri,
      :manifest_uri, :requested_images, :requested_images_detail,
      :order_fee, :total_images_in_resource
    ]
    atts.each do |a|
      case a
      when :order_fee
        order_fee = digital_collections_order.order_fee
        if order_fee
          serialized[:order_fee] = serialize_order_fee(order_fee)
          # serialized[:order_fee][:unit_fee_options] = unit_fee_options(digital_collections_order)
        end
      else
        serialized[a] = digital_collections_order.send(a)
      end
    end
    serialized
  end


    # def active_access_session
    #   session = object.item.active_access_session
    #   if session
    #     response_hash = {
    #       start_datetime: session.start_datetime,
    #       end_datetime: session.end_datetime
    #     }
    #     session.users.each do |user|
    #       (response_hash[:users] ||= []) << {
    #         id: user.id,
    #         email: user.email,
    #         first_name: user.first_name,
    #         last_name: user.last_name,
    #         display_name: user.display_name
    #       }
    #     end
    #     response_hash
    #   end
    # end


    # def open_orders
    #   orders = []
    #   object.item.open_orders.each do |o|
    #     order = o.attributes.with_indifferent_access
    #     order[:order_type] = o.order_type
    #     order[:users] = o.users.map { |u|
    #       {
    #         id: u.id,
    #         last_name: u.last_name,
    #         first_name: u.first_name,
    #         display_name: u.display_name,
    #         email: u.email
    #       }
    #     }
    #     orders << order
    #   end
    #   orders
    # end


end
