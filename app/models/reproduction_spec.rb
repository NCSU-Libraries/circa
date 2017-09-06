class ReproductionSpec < ActiveRecord::Base
  belongs_to :item_order
  belongs_to :reproduction_format

  def unit_total
    pages
  end

end
