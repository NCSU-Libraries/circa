class ItemsController < ApplicationController

  include SolrUtilities

  before_action :set_item, only: [
    :show, :edit, :update, :destroy, :update_state, :check_out, :check_in,
    :receive_at_temporary_location, :history, :obsolete, :change_active_order,
    :update_from_source
  ]

  before_action :set_params

  before_action :verify_order_id, :verify_check_out_permitted, :verify_users, only: [ :check_out ]

  before_action :get_active_access_session, only: [ :check_in ]

  before_action :verify_event_permitted, only: [ :check_in, :update_state ]

  def index
    @params = params
    @params[:sort] ||= 'resource_title asc'
    @list = get_list_via_solr('item')
    @api_response = {
      items: @list,
      meta: { pagination: pagination_params }
    }
    render json: @api_response
  end


  def pending_transfers
    @params = params
    get_pending_transfers()
    @api_response = {
      facilities: @facilities,
      total_items: @total_items,
      total_orders: @orders.length,
      orders: @orders
    }
    render json: @api_response
  end


  def returns_in_transit
    @params = params
    get_returns_in_transit()
    @api_response = {
      facilities: @facilities,
      total_items: @total_items,
      total_orders: @orders.length,
      orders: @orders
    }
    render json: @api_response
  end


  def items_in_transit_for_use
    @params = params
    get_items_in_transit_for_use()
    @api_response = {
      locations: @locations,
      total_items: @total_items,
      total_orders: @orders.length,
      orders: @orders
    }
    render json: @api_response
  end


  def digital_object_requests
    @params = params
    get_digital_object_requests()
    @api_response = {
      total_items: @total_items,
      total_orders: @orders.length,
      orders: @orders
    }
    render json: @api_response
  end


  def transfer_list
    @params = params
    get_pending_transfers()
    render layout: 'layouts/print'
  end


  def returns_list
    @params = params
    get_returns_in_transit()
    render layout: 'layouts/print'
  end


  def items_in_transit_for_use_list
    @params = params
    get_items_in_transit_for_use()
    render layout: 'layouts/print'
  end


  def show
    render json: @item
  end


  # def create

  # end


  # Will create one or more items from the ArchivesSpace record corresponding to params[:archivesspace_uri]
  # If any item already exists it will be updated
  # Returns array of item records (including both new and updated records)
  def create_from_archivesspace
    begin
      if params[:archivesspace_uri] && !params[:archivesspace_uri].blank?
        @items = Item.create_or_update_from_archivesspace(params[:archivesspace_uri], params)
        render json: @items ? @items : {}
        return
      else
        render json: { error: { detail: 'Bad request: No ArchivesSpace URI provided' } }, status: 400
        return
      end
    rescue Exception => e
      logger.error e
      render json: { error: { detail: "Internal server error: #{e.message} - #{e.backtrace.inspect}" } }, status: 500
    end
  end


  # Will create one item from the NCSU catalog ID and item id provided
  # If item already exists it will be updated
  # Returns single item record
  def create_from_catalog
    if (params[:catalog_record_id].blank? || params[:catalog_item_id].blank?)
      raise CircaExceptions::BadRequest, "Catalog record id and item id were not provided."
    else
      @item = Item.create_or_update_from_catalog(params[:catalog_record_id], params[:catalog_item_id])
      if !@item
        raise CircaExceptions::BadRequest, "No catalog record found matching the id provided."
      else
        render json: @item
      end
    end
  end


  def update
    @item.update!(item_params)
    render json: @item
  end


  def update_from_source
    # case @item.source
    # when 'archivesspace'
    #   archivesspace_uris = []
    #   @item.item_archivesspace_records.each { |iar| archivesspace_uris << iar.archivesspace_uri }
    #   archivesspace_uris.each do |uri|
    #     options = { digital_object: @item.digital_object }
    #     options[:force_update] = @item.digital_object ? true : nil
    #     Item.create_or_update_from_archivesspace(uri, options)
    #   end
    #   @item.reload
    # when 'catalog'
    #   icr = @item.item_catalog_record
    #   if icr
    #     Item.create_or_update_from_catalog(icr.catalog_record_id, icr.catalog_item_id)
    #     @item.reload
    #   end
    # end
    @item.update_from_source
    @item.reload
    render json: @item
  end


  def delete
    if @item.destroy
      render 'index', info: "Item deleted."
    end
  end


  def destroy
  end


  def obsolete
    @item.mark_as_obsolete
    puts "IT HAPPENED"
    @item.reload
    # render json: nil, status: 204
    render json: @item
  end


  def update_state
    event = params[:event].to_sym
    if ![:check_in, :check_out].include?(event)
      metadata = transition_metadata
      if event == :return
        metadata[:location_id] = @item.current_location_id
      end
      @item.trigger!(event, metadata)
      render json: @item
    end
  end


  def check_out
    if @item.in_use?
      raise CircaExceptions::BadRequest("This item is already in use")
    else
      @access_session = AccessSession.create_with_users(item_id: @item.id, order_id: params[:order_id], users: params[:users])
      @item.trigger!(:check_out, transition_metadata)
      @order = Order.find params[:order_id]
      @item.reload
      render json: @item
    end
  end


  def receive_at_temporary_location
    @order = Order.find params[:order_id]
    metadata = transition_metadata
    metadata[:location_id] = @order.location_id
    @item.trigger!(:receive_at_temporary_location, metadata)
    @item.update_attributes(current_location_id: @order.location_id)
    @item.reload
    render json: @item
  end


  def check_in
    @access_session.close
    @order = Order.find params[:order_id]
    metadata = transition_metadata
    metadata[:location_id] = @order.location_id
    @item.trigger!(:check_in, metadata)
    render json: @item
  end


  def history
    render json: @item, serializer: ItemHistorySerializer
  end


  def change_active_order
    if params[:order_id]
      @item.change_active_order_id(params[:order_id])
      render json: @item
    else
      raise CircaExceptions::BadRequest, 'No new order id was provided'
    end
  end


  def deactivate_for_order
    if params[:order_id]
      @item.deactivate_for_order(order_id)
      @item.reload
      render json: @item
    else
      raise CircaExceptions::BadRequest, 'No new order id was provided'
    end
  end


  def reactivate_for_order
    if params[:order_id]
      @item.activate_for_order(order_id)
      @item.reload
      render json: @item
    else
      raise CircaExceptions::BadRequest, 'No new order id was provided'
    end
  end


  private


  def item_params
    params.require(:item).permit(:resource_title, :resource_identifier, :resource_uri, :container, :uri, :permanent_location_id, :current_location_id)
  end


  # Use callbacks to share common setup or constraints between actions
  def set_item
    @item = Item.find(params[:id])
  end


  def set_params
    @params = params
  end


  def transition_metadata
    { user_id: current_user.id, order_id: @params[:order_id] }
  end


  def verify_order_id
    if !params[:order_id]
      raise CircaExceptions::BadRequest, "Order ID must be provided with check out request"
    end
  end


  def event_metadata(event = nil)
    event ||= params[:event];
    { user_id: current_user.id, event: event, order_id: params[:order_id] }
  end


  def verify_check_out_permitted
    permitted = true
    if !@item.permitted_events.include?(:check_out)
      permitted = false
      error_message = "Item cannot be checked out at this time"
    elsif @item.in_use?
      permitted = false
      error_message = "Item is already checked out"
    end
    if !permitted
      raise CircaExceptions::BadRequest, error_message
    end
  end


  def verify_event_permitted
    if params[:event] && !@item.permitted_events.include?(params[:event].to_sym)
      raise CircaExceptions::BadRequest, "Item cannot be checked out at this time"
    end
  end


  def verify_users
    if !params[:users]
      raise CircaExceptions::BadRequest, "One or more User IDs required"
    end
  end


  def get_active_access_session
    @access_session = @item.active_access_session
    if !@access_session
      raise CircaExceptions::BadRequest, "There is no active AccessSession associated with this item (it is not checked out)"
    end
  end


  def verify_event_permitted
    if params[:event]
      event = params[:event].to_sym
    elsif params[:action] == 'check_in'
      event = :check_in
    else
      event = nil
    end

    if !event || !@item.permitted_events.include?(event)
      raise CircaExceptions::BadRequest, event ? "#{event} is not currently permitted" : "No event was specified"
    end
  end


  def get_digital_object_requests
    @orders = {}
    @params[:q] = "digital_object:true AND state:ordered"
    @params[:defType] = 'lucene'
    @params[:sort] = 'next_scheduled_use_date asc'
    @params[:per_page] = 1000
    @items = get_list_via_solr('item')

    @items.each do |i|
      i = i.with_indifferent_access
      i[:open_order_ids].each do |oid|
        @orders[oid] ||= { items: [] }
        @orders[oid][:items] << i
      end
    end
    @total_items = @items.length
    @orders.with_indifferent_access
  end


  def get_pending_transfers
    @items = get_items_in_state(:ordered, 'next_scheduled_use_date asc')

    puts @items.inspect

    @orders = {}
    @facilities = []

    @items.each do |i|
      i = i.with_indifferent_access
      i[:open_order_ids].each do |oid|
        @orders[oid] ||= { item_orders: [] }
        item_order = ItemOrder.where(order_id: oid, item_id: i[:id]).first
        if item_order
          io = item_order.attributes
          io['item'] = i
          @orders[oid][:item_orders] << io
        end
      end

      if i[:permanent_location]
        @facilities << i[:permanent_location][:facility]
      else
        @facilities << 'unknown'
      end

    end


    @total_items = @items.length
    @facilities.uniq!
    @orders.with_indifferent_access
  end


  def get_returns_in_transit
    @items = get_items_in_state(:returning_to_permanent_location)
    @orders = {}
    @facilities = []
    @items.each do |i|
      i = i.with_indifferent_access
      i[:open_order_ids].each do |oid|
        @orders[oid] ||= { items: [] }
        @orders[oid][:items] << i
      end
      if i[:permanent_location]
        @facilities << i[:permanent_location][:facility]
      else
        @facilities << 'unknown'
      end
    end
    @total_items = @items.length
    @facilities.uniq!
    @orders.with_indifferent_access
  end


  def get_items_in_transit_for_use
    @params[:filters] ||= {}
    @params[:filters]['item_state'] = 'in_transit_to_temporary_location'
    @params[:per_page] = 1000
    orders_raw = get_list_via_solr('order')

    @orders = {}
    @locations = []
    @total_items = 0

    orders_raw.each do |o|
      oid = o['id']

      order = Order.find_by(id: oid)

      if order.temporary_location
        location = order.temporary_location.title
      else
        location = "unknown/not set"
      end

      if location
        @locations << location
      end

      if order && order.items.length > 0
        @orders[oid] ||= { items: [], location: location }.with_indifferent_access
        order.items.each do |item|
          if item && item.current_state == :in_transit_to_temporary_location
            @orders[oid][:items] << item.json_data(:hash).with_indifferent_access
            @total_items += 1
          end
        end
      end
    end

    puts "***"
    puts @orders.inspect

    @locations.uniq!
    @orders.with_indifferent_access
  end


  def get_items_in_state(state, sort=nil)
    @params[:filters] ||= {}
    @params[:per_page] = 1000
    @params[:filters]['state'] = state.to_s
    @params[:sort] = sort

    puts @params[:filters]

    get_list_via_solr('item')
  end

end
