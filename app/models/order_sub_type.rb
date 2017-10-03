class OrderSubType < ActiveRecord::Base

  belongs_to :order_type
  has_many :orders
  belongs_to :default_location, class_name: 'Location'
end
