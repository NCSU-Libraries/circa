class OrdersController < ApplicationController

  include SolrUtilities

  before_action :set_order, only: [
    :show, :edit, :update, :destroy, :update_state, :add_associations, :call_slip, :deactivate_item, :activate_item, :history
  ]

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
      render json: @order
    end
  end


  def create
    params['order']['location_id'] = params['order']['temporary_location'] ? params['order']['temporary_location']['id'] : nil

    get_association_data_from_params(params)
    @order = Order.create!(order_params)
    @params = params

    update_associations

    # Consider revising - update_index is called twice, once after order is created and again here
    @order.update_index

    send_notifications

    render json: @order
  end


  def update
    if params['order']['temporary_location']
      params['order']['location_id'] = params['order']['temporary_location']['id']
    end
    get_association_data_from_params(params)
    @order.update!(order_params)

    update_associations

    @order.reload

    send_notifications

    render json: @order
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
        item_order.deactivate
        @order.reload
        render json: @order
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
        render json: @order
      else
        raise CircaExceptions::BadRequest, "Item #{ params[:item_id] } is not associated with this order"
      end
    end
  end


  def add_associations
    response = {}
    status = 200
    message = nil

    if params[:items]
      # Request should fail if any of the URIs provided are invalid
      if check_values(:archivesspace_archival_object_uri, params[:items])
        params[:items].each do |archivesspace_uri|
          if !@order.add_items_from_archivesspace(archivesspace_uri)
            status = 500
          end
        end
      else
        status = 400
        message = "One or more ArchivesSpace URIs included in the request was invalid."
      end

    elsif params[:users]
      params[:users].each do |user_id|
        if !OrderUser.create!(order_id: @order.id, user_id: user_id)
          status = 500
        end
      end

    elsif params[:assignees]
      params[:assignees].each do |user_id|
        if !OrderAssignment.create!(order_id: @order.id, user_id: user_id)
          status = 500
        end
      end

    elsif params[:notes]
      # TK

    else
      status = 400
      message = "No valid associations provided"
    end

    if status == 200
      render json: @order
      return
    else
      if status == 400
        response[:error] = { status: 403, detail: "Bad request: #{message}"}
      elsif status == 500
        response[:error] = { status: 500, detail: "Internal server error"}
      end
      render json: response, status: status
    end

  end



  def delete_associations
    response = {}
    status = 200
    message = nil
    if params[:items]
      # TK

    elsif params[:users]
      # TK

    elsif params[:assignees]
      # TK

    elsif params[:notes]
      # TK

    else
      status = 400
      message = "No valid associations provided"
    end

    if status == 400
      response[:error] = { status: 403, detail: "Bad request: #{message}" }
    elsif status == 500
      response[:error] = { status: 500, detail: "Internal server error" }
    end

    render json: response, status: status
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


  def history
    render json: @order, serializer: OrderHistorySerializer
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



  private



  def order_params
    params.require(:order).permit(:access_date_start, :access_date_end, :type, :location_id, :order_type_id, :order_sub_type_id, :user_id)
  end


  # Use callbacks to share common setup or constraints between actions
  def set_order
    @order = Order.find(params[:id])
  end


  def get_association_data_from_params(params)
    @items = params[:order][:items] || []
    @item_orders = params[:order][:item_orders] || []
    @digital_image_orders = params[:order][:digital_image_orders] || []
    @users = params[:order][:users] || []
    if @users && params[:order][:primary_user_id]
      @users.map! do |user|
        user[:primary] = params[:order][:primary_user_id] == user[:id] ? true : nil
        user
      end
    end
    @assignees = params[:order][:assignees] || []
    @notes = params[:order][:notes] || []
    @course_reserve = params[:order][:course_reserve]
    @new_assignees = []
    @new_users = []
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
        @order.item_orders.create!(item_id: item_order['item_id'], archivesspace_uri: item_order['archivesspace_uri'], user_id: current_user.id, active: true)
      else
        existing_item_order = @order.item_orders.where(item_id: item_order['item_id']).first
        existing_item_order.update_attributes(archivesspace_uri: item_order['archivesspace_uri'])
        @order.reload
        # delete id from @existing_items array to track associations to be deleted
        @existing_items.delete(item_order['item_id'])
      end
    end

    @existing_items.each do |item_id|
      @order.item_orders.where(item_id: item_id).each { |io| io.destroy! }
    end
  end


  def update_digital_image_orders
    attributes_from_params = lambda do |digital_image_order|
      atts = {
        order_id: @order.id,
        image_id: digital_image_order['image_id'],
        detail: digital_image_order['detail'],
        label: digital_image_order['label'],
        display_uri: digital_image_order['display_uri'],
        manifest_uri: digital_image_order['manifest_uri'],
        requested_images: digital_image_order['requested_images']
      }
    end

    @existing_digital_image_orders = []
    @order.digital_image_orders.each { |dio| @existing_digital_image_orders << dio.image_id }
    @digital_image_orders.each do |digital_image_order|
      # add
      if !@existing_digital_image_orders.include?(digital_image_order['image_id'])
        @order.digital_image_orders.create!( attributes_from_params.(digital_image_order) )
      else
        existing = DigitalImageOrder.find_by(order_id: @order.id, image_id: digital_image_order['image_id'])
        existing.update_attributes(attributes_from_params.(digital_image_order))
        @existing_digital_image_orders.delete(digital_image_order['image_id'])
      end
    end
    @existing_digital_image_orders.each do |image_id|
      @order.digital_image_orders.where(image_id: image_id).each { |dio| dio.destroy! }
    end
  end


  def update_users
    @existing_users = []
    @order.users.each { |p| @existing_users << p.id }

    @users.each do |user|
      if !@existing_users.include?(user['id'])
        @order.order_users.create!(user_id: user['id'], primary: user['primary'])
      else
        # delete id from @existing_users array to track associations to be deleted
        # and update order_user to set primary
        @existing_users.delete(user['id'])
        @order.order_users.where(user_id: user['id']).first.update_attributes(primary: user['primary'])
      end
    end

    @existing_users.each do |user_id|
      @order.order_users.where(user_id: user_id).each { |op| op.destroy! }
    end
  end


  def update_notes
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


  def update_course_reserve
    @order.create_or_update_course_reserve(@course_reserve.symbolize_keys)
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


  def update_associations
    if @users
      update_users
    end

    if @items
      update_items
    end

    if @notes
      update_notes
    end

    if @assignees
      update_assignees
    end

    if @course_reserve
      update_course_reserve
    end

    if @digital_image_orders
      update_digital_image_orders
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

end
