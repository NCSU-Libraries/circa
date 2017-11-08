class AddDefaultFeeToReproductionFormat < ActiveRecord::Migration
  def change
    add_column :reproduction_formats, :default_unit_fee, :decimal, precision: 7, scale: 2
  end
end
