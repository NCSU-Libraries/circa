class OrderMailer < ApplicationMailer

  require 'mail'

  from_address = Mail::Address.new ENV['circa_email']
  from_address.display_name = ENV['circa_email_display_name']

  default  from: from_address.format, bcc: ENV['order_notification_default_email']

  def assignee_email(order, assignee, order_url)
    to_address = Mail::Address.new assignee.email
    to_address.display_name = assignee.display_name.dup

    @order = order
    @assignee = assignee
    @order_url = order_url

    cc = nil
    if ENV['order_notification_digital_items_email'] && @order.has_digital_items?
      cc = ENV['order_notification_digital_items_email']
    end

    mail(to: to_address.format, cc: cc, subject: "Circa Order #{order.id}")
  end

end
