class OrderFee < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  def total
    unit_total = record.unit_total * per_unit_fee
    unit_total + per_order_fee
  end

end
