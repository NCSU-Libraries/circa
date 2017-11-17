class DigitalImageOrder < ActiveRecord::Base

  belongs_to :order
  has_one :order_fee, as: :record

  serialize(:requested_images)

  before_save do
    self.requested_images.sort!
  end

  def unit_total
    requested_images.count
  end

end
