class OrderFee < ActiveRecord::Base

  belongs_to :record, polymorphic: true

  def per_unit_total
    record.class == Order ? 0 : record.unit_total * per_unit_fee
  end

  def total
    per_unit_total + per_order_fee
  end

end
