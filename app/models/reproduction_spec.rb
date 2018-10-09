class ReproductionSpec < ApplicationRecord

  belongs_to :item_order
  belongs_to :reproduction_format

  def unit_total
    pages
  end


  def item
    item_order.item
  end


  def order
    item_order.order
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include ReproductionSpecCustom
  rescue
  end

end
