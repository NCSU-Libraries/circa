class UpdateReproductionFormats < ActiveRecord::Migration
  def change
    add_column :reproduction_formats, :description, :text
    rename_column :reproduction_formats, :default_unit_fee, :default_unit_fee_internal
    add_column :reproduction_formats, :default_unit_fee_external, :decimal, precision: 7, scale: 2
  end
end
