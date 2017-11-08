class CreateReproductionFormats < ActiveRecord::Migration
  def change
    create_table :reproduction_formats do |t|
      t.string :name
      t.decimal :default_unit_fee, precision: 7, scale: 2
      t.timestamps null: false
    end
  end
end
