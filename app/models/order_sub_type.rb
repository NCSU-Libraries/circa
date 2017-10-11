class OrderSubType < ActiveRecord::Base

  belongs_to :order_type
  has_many :orders
  belongs_to :default_location, class_name: 'Location'

  def self.name_from_id(id)
    self.where(id: id).limit(1).pluck(:name)[0]
  end

end
