class DigitalCollectionsOrder < ApplicationRecord

  serialize(:requested_images)

  belongs_to :order
  has_one :order_fee, as: :record

  before_save do
    if !self.requested_images.blank?
      self.requested_images.sort!
    end
  end


  def unit_total
    requested_images.count
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include DigitalCollectionsOrderCustom
  rescue
  end

end
