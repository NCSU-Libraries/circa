class OrderFee < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  def total
  end

end
