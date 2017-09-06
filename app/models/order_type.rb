class OrderType < ActiveRecord::Base

  has_many :order_sub_types

  def orders
    order_sub_types.flat_map { |ost| ost.orders }
  end

end
