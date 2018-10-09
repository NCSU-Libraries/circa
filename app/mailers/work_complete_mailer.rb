class WorkCompleteMailer < OrderMailer

  def assignee_email(order, assignee, order_url)
    to_address = Mail::Address.new assignee.email
    to_address.display_name = assignee.display_name.dup

    @order = order
    @assignee = assignee
    @order_url = order_url
    @item_orders = ItemOrder.where(order_id: order.id).includes(:item, :reproduction_spec, :order_fee)
    @digital_collections_orders = DigitalCollectionsOrder.where(order_id: order.id)

    cc = nil
    if ENV['order_notification_digital_items_email'] && @order.has_digital_items?
      cc = ENV['order_notification_digital_items_email']
    end

    mail(to: to_address.format, cc: cc, subject: "Circa Reproduction Order #{order.id} is ready!")
  end

end
