class InvoicesController < ApplicationController

  # Load custom concern if present
  begin
    include InvoicesControllerCustom
  rescue
  end


  def show
    @invoice = Invoice.find_or_create_for_order(params[:order_id])
    @invoice.set_date_and_id
    @custom_to = nil
    if !@invoice.custom_to.blank?
      @custom_to = @invoice.custom_to.gsub(/\s*[\n\r]+\s*/, '<br>')
    end
    @order = Order.find(params[:order_id])
    @user = @order.primary_user
    @item_orders = @order.item_orders.includes(:order_fee, :item, :reproduction_spec)
    @digital_collections_orders = @order.digital_collections_orders.includes(:order_fee)
    @order_fees_total = @order.order_fees_total
    @invoice_date = @invoice.invoice_date
    @invoice_id = @invoice.invoice_id
    render layout: 'layouts/print'
  end


  def update
    set_invoice_and_order
    @order_id = params[:order_id]
    @invoice.update_attributes(invoice_params)
    @api_response = SerializeRecord.call(@invoice)
    render json: @api_response
  end


  # Load custom concern if present
  begin
    include InvoicesControllerCustom
  rescue
  end


  private


  def invoice_params
    params.require(:invoice).permit(:order_id, :invoice_date, :payment_date,
        :attn, :invoice_id, :custom_to)
  end


  def set_invoice_and_order
    if params[:order_id]
      @order = Order.find params[:order_id].to_i
      @invoice = Invoice.find_or_create_for_order(@order.id, invoice_params)
      raise ActiveRecord::RecordNotFound if !@invoice
    elsif params[:id]
      @invoice = Invoice.find params[:id]
      @order = @invoice.order
    end
  end

end
