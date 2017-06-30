class OrderSubType < ActiveRecord::Base

  belongs_to :order_type
  has_many :orders

end
