class DigitalImageOrder < ActiveRecord::Base

  belongs_to :order
  serialize(:requested_images)

  before_save do
    self.requested_images.sort!
  end

end
