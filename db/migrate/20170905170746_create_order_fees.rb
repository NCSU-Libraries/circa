class CreateOrderFees < ActiveRecord::Migration[5.2]
  def change
    create_table :order_fees do |t|
      t.integer :record_id
      t.string :record_type
      t.decimal :per_unit_fee, precision: 7, scale: 2
      t.decimal :per_order_fee, precision: 7, scale: 2
      t.text :note
      t.timestamps null: false
    end
  end
end
