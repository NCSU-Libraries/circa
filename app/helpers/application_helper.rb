module ApplicationHelper

  def options(option)
    @options = {
      send_order_notifications: ENV['send_order_notifications'],
      use_devise_passwords: ENV['use_devise_passwords']
    }
    @options[option]
  end

end
