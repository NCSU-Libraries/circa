class CreateReproductionSpecs < ActiveRecord::Migration[5.2]
  def change
    create_table :reproduction_specs do |t|
      t.integer :item_order_id
      t.text :detail
      t.integer :pages
      t.integer :reproduction_format_id
      t.timestamps null: false
    end
  end
end
