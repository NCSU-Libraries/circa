class OrderType < ActiveRecord::Base

  has_many :orders
  has_many :order_sub_types

end
