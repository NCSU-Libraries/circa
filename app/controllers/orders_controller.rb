class OrdersController < ApplicationController

  include SolrList


  before_action :set_order, only: [
    :show, :edit, :update, :destroy, :update_state, :add_associations,
    :call_slip, :deactivate_item, :activate_item, :history, :invoice
  ]

  before_action :set_paper_trail_whodunnit

  def index
    @params = params
    @params[:sort] ||= 'access_date_start desc'
    @list = get_list_via_solr('order')

    @api_response = {
      orders: @list,
      meta: { pagination: pagination_params }
    }
    render json: @api_response
  end


  def show
    if @order.deleted
      raise CircaExceptions::BadRequest, "Order ##{@order.id} has been deleted."
    else
      render json: SerializeOrder.call(@order)
    end
  end


  def create
    # params['order']['location_id'] = params['order']['temporary_location'] ? params['order']['temporary_location']['id'] : nil
    get_association_data_from_params(params)
    @order = Order.create!(order_params)
    @params = params
    update_associations(:create)
    # Consider revising - update_index is called twice, once after order is created and again here
    @order.update_index
    send_notifications
    render json: SerializeOrder.call(@order)
  end


  def update
    get_association_data_from_params(params)
    set_cleanup_reproduction_associations()
    post_update_event = params[:event]
    @order.update!(order_params)
    update_associations

    if post_update_event
      @order.trigger(post_update_event.to_sym)
    end

    @order.reload
    send_notifications
    render json: SerializeOrder.call(@order)
  end


  def update_state
    if params[:event]
      trigger_event(@order, params[:event].to_sym)
    else
      render json: { error: "Bad request" }, status: 400
      return
    end
  end


  def deactivate_item
    if !params[:item_id]
      raise CircaExceptions::BadRequest, "No item id was provided."
    else
      if @order && @order.item_ids.include?(params[:item_id].to_i)
        item_order = @order.item_orders.where(item_id: params[:item_id]).first
        item_order.deactivate(current_user.id)
        @order.reload
        render json: SerializeOrder.call(@order)
      else
        raise CircaExceptions::BadRequest, "Item #{ params[:item_id] } is not associated with this order"
      end
    end
  end


  def activate_item
    if !params[:item_id]
      raise CircaExceptions::BadRequest, "No item id was provided."
    else
      if @order && @order.item_ids.include?(params[:item_id].to_i)
        item_order = @order.item_orders.where(item_id: params[:item_id]).first
        item_order.activate
        @order.reload
        render json: SerializeOrder.call(@order)
      else
        raise CircaExceptions::BadRequest, "Item #{ params[:item_id] } is not associated with this order"
      end
    end
  end


  def call_slip
    @current_user = current_user
    if params[:item_id]
      @item = Item.find(params[:item_id])
      @items = [ @item ]
    else
      @items = @order.items
    end
    render layout: 'layouts/print'
  end


  # def invoice
  #   @user = @order.primary_user
  #   @item_orders = @order.item_orders.includes(:order_fee, :item, :reproduction_spec)
  #   @digital_collections_orders = @order.digital_collections_orders.includes(:order_fee)
  #   @order_fees_total = @order.order_fees_total
  #   @invoice_date = @order.invoice_date || DateTime.now.to_date
  #   @invoice_id = @order.invoice_id || @order.generate_invoice_id
  #   render layout: 'layouts/print'
  # end


  def history
    render json: SerializeOrderHistory.call(@order)
  end


  def course_reserves
    @params = params
    @params[:filters] = { order_sub_type_name: 'course_reserve', open: true }
    @list = get_list_via_solr('order')
    @api_response = {
      orders: @list,
      meta: { pagination: pagination_params }
    }
    render json: @api_response
  end


  # Load custom concern if present
  begin
    include OrdersControllerCustom
  rescue
  end


  private


  def order_params
    params.require(:order).permit(:access_date_start, :access_date_end, :type,
        :location_id, :order_sub_type_id, :user_id, :cloned_order_id,
        :invoice_date, :invoice_payment_date, :invoice_attn)
  end


  # Use callbacks to share common setup or constraints between actions
  def set_order
    @order = Order.find(params[:id])
  end


  def get_association_data_from_params(params)
    order = params[:order]
    @items = order[:items] || []
    @item_orders = order[:item_orders] || []
    @digital_collections_orders = order[:digital_collections_orders] || []
    @users = order[:users] || []
    if @users && order[:primary_user_id]
      @users.map! do |user|
        user[:primary] = order[:primary_user_id] == user[:id] ? true : nil
        user
      end
    end
    @assignees = order[:assignees] || []
    @notes = order[:notes] || []
    @course_reserve = order[:course_reserve]
    @new_assignees = []
    @order_sub_type_name = OrderSubType.name_from_id(order[:order_sub_type_id])
    @order_fee = (@order_sub_type_name == 'reproduction_fee' && order[:order_fee]) ?
        order[:order_fee] : nil
    @invoice = order[:invoice] || nil
  end


  def update_associations(action = :update)
    if @users
      update_users
    end

    if @items
      update_items
    end

    if @notes
      update_notes(action)
    end

    if @assignees
      update_assignees
    end

    if @course_reserve
      update_course_reserve(action)
    end

    if @digital_collections_orders
      update_digital_collections_orders
    end

    update_order_fee
  end


  # This process will not create new items, only associations
  # Creation of items during Order new/edit should be provided in the view via AJAX requests to items_controller
  def update_items
    @existing_items = []
    @order.items.each { |i| @existing_items << i.id }

    # detail and reproduction_pages will come in as attributes of items, but they actually belong to the item_order
    # so look for those, then add them to the correct record in @item_orders

    @item_orders.each do |item_order|
      # add item to order
      if !@existing_items.include?(item_order['item_id'].to_i)
        item_order_record = @order.item_orders.create!(item_id: item_order['item_id'], archivesspace_uri: item_order['archivesspace_uri'], user_id: current_user.id, active: true)
      else
        item_order_record = @order.item_orders.where(item_id: item_order['item_id']).first
        item_order_record.update_attributes(archivesspace_uri: item_order['archivesspace_uri'])
        @order.reload
        # delete id from @existing_items array to track associations to be deleted
        @existing_items.delete(item_order['item_id'])
      end

      if item_order['reproduction_spec']
        create_or_update_reproduction_spec(item_order_record.id, item_order['reproduction_spec'])
      end

      # handle fees
      if @order_sub_type_name == 'reproduction_fee'
        if item_order['order_fee']
          create_or_update_order_fee(item_order_record.id, 'ItemOrder', item_order['order_fee'])
        end
      else
        # delete any existing fee for this item_order if it exists
        OrderFee.where(record_id: item_order_record.id,
            record_type: 'ItemOrder').each { |f| f.destroy! }
      end
    end

    @existing_items.each do |item_id|
      @order.item_orders.where(item_id: item_id).each { |io| io.destroy! }
    end
  end


  def create_or_update_reproduction_spec(item_order_id, reproduction_spec_data)
    atts = {
      detail: reproduction_spec_data['detail'],
      pages: reproduction_spec_data['pages'],
      reproduction_format_id: reproduction_spec_data['reproduction_format_id']
    }
    existing_reproduction_spec = ReproductionSpec.find_by(item_order_id: item_order_id)
    if existing_reproduction_spec
      existing_reproduction_spec.update_attributes(atts)
    else
      atts[:item_order_id] = item_order_id
      ReproductionSpec.create!(atts)
    end
  end


  def create_or_update_order_fee(record_id, record_type, order_fee_data)
    atts = {
      per_unit_fee: order_fee_data['per_unit_fee'],
      per_order_fee: order_fee_data['per_order_fee'],
      per_order_fee_description: order_fee_data['per_order_fee_description'],
      note: order_fee_data['note'],
      unit_fee_type: order_fee_data['unit_fee_type']
    }

    [:per_unit_fee, :per_order_fee].each do |key|
      atts[key] = atts[key].to_f <= 0 ? nil : atts[key]
    end

    existing_order_fee = OrderFee.find_by(record_id: record_id, record_type: record_type)
    if existing_order_fee
      existing_order_fee.update_attributes(atts)
    else
      atts.merge!({ record_id: record_id, record_type: record_type })
      OrderFee.create!(atts)
    end
  end


  def update_digital_collections_orders
    attributes_from_params = lambda do |digital_collections_order|
      {
        order_id: @order.id,
        resource_identifier: digital_collections_order['resource_identifier'],
        detail: digital_collections_order['detail'],
        resource_title: digital_collections_order['resource_title'],
        display_uri: digital_collections_order['display_uri'],
        manifest_uri: digital_collections_order['manifest_uri'],
        requested_images: digital_collections_order['requested_images'],
        requested_images_detail: digital_collections_order['requested_images_detail'],
        total_images_in_resource: digital_collections_order['total_images_in_resource']
      }
    end

    @existing_digital_collections_orders = []
    @order.digital_collections_orders.each { |dio| @existing_digital_collections_orders << dio.resource_identifier }
    @digital_collections_orders.each do |digital_collections_order|
      # add
      if !@existing_digital_collections_orders.include?(digital_collections_order['resource_identifier'])
        digital_collections_order_record = @order.digital_collections_orders.create!( attributes_from_params.(digital_collections_order) )
      else
        digital_collections_order_record = DigitalCollectionsOrder.find_by(order_id: @order.id, resource_identifier: digital_collections_order['resource_identifier'])
        digital_collections_order_record.update_attributes(attributes_from_params.(digital_collections_order))
        @existing_digital_collections_orders.delete(digital_collections_order['resource_identifier'])
      end

      if digital_collections_order['order_fee']
        create_or_update_order_fee(digital_collections_order_record.id, 'DigitalCollectionsOrder', digital_collections_order['order_fee'])
      end
    end

    @existing_digital_collections_orders.each do |resource_identifier|
      @order.digital_collections_orders.where(resource_identifier: resource_identifier).each { |dio| dio.destroy! }
    end
  end


  def update_users
    @existing_users = []
    @order.users.each { |p| @existing_users << p.id }

    @users.each do |user|
      if !@existing_users.include?(user['id'])
        @order.order_users.create!(user_id: user['id'], primary: user['primary'], remote: user['remote'])
      else
        # delete id from @existing_users array to track associations to be deleted
        # and update order_user to set primary
        @existing_users.delete(user['id'])
        @order.order_users.where(user_id: user['id']).first.update_attributes(primary: user['primary'], remote: user['remote'])
      end
    end

    @existing_users.each do |user_id|
      @order.order_users.where(user_id: user_id).each { |op| op.destroy! }
    end
  end


  def update_notes(action = :update)
    if (@order.notes.length == 0) && (@notes.length == 0)
      return
    elsif (@order.notes.length == 0) && (@notes.length > 0)
      @notes.each { |n| @order.notes.create!(content: n['content']) }
    elsif (@notes.length == 0) && (@order.notes.length > 0)
      @order.notes.each { |n| n.destroy! }
    else
      notes_length = @order.notes.length > @notes.length ? @order.notes.length : @notes.length
      (0..(notes_length - 1)).to_a.each do |i|
        if @order.notes[i] && @notes[i]
          @order.notes[i].update_attributes(content: @notes[i]['content'])
        elsif !@order.notes[i] && @notes[i]
          @order.notes.create!(content: @notes[i]['content'])
        elsif @order.notes[i] && !@notes[i]
          @order.notes[i].destroy!
        end
      end
    end
  end


  def update_course_reserve(action = :update)
    if action == :create
      @course_reserve.delete('id')
    end
    @order.create_or_update_course_reserve(@course_reserve)
  end


  def update_assignees
    @existing_assignees = []
    @order.assignees.each { |a| @existing_assignees << a.id }

    @assignees.each do |assignee|
      if !@existing_assignees.include?(assignee['id'])
        @order.order_assignments.create!(user_id: assignee['id'])
        # add assignee to new_assignees for email notification
        @new_assignees << User.find_by(id: assignee['id'])
      else
        # delete id from @existing_users array to track associations to be deleted
        @existing_assignees.delete(assignee['id'])
      end
    end

    @existing_assignees.each do |user_id|
      @order.order_assignments.where(user_id: user_id).each { |oa| oa.destroy! }
    end
  end


  def update_order_fee
    @existing_order_fee = @order.order_fee
    if @existing_order_fee && !@order_fee
      @existing_order_fee.destroy
    elsif @order_fee
      create_or_update_order_fee(@order.id, 'Order', @order_fee)
    end
  end


  def send_notifications
    order_url = "#{request.host_with_port}#{relative_url_root}/#/orders/#{@order.id}"

    if @new_assignees && @new_assignees.length > 0
      @new_assignees.each do |a|
        OrderMailer.assignee_email(@order, a, order_url).deliver_later
      end
    end
  end


  # If the order_type has changed from reproduction to something else,
  #   we need to delete associations specific to reproduction orders
  def set_cleanup_reproduction_associations
    @cleanup_reproduction_associations = nil
    if @order.order_type.name == 'reproduction' &&
        params[:order][:order_type_id] != @order.order_type_id
      @cleanup_reproduction_associations = true
    end
  end

end
