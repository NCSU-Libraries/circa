class OrderFee < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  def per_unit_total
    if record.class == Order || !(record.unit_total && per_unit_fee)
      0
    else
      record.unit_total * per_unit_fee
    end
  end

  def total
    if per_order_fee
      per_unit_total + per_order_fee
    else
      per_unit_total
    end
  end

end
