class CreateDigitalImageOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :digital_image_orders do |t|
      t.integer :order_id, null: false
      t.string :image_id, null: false
      t.text :detail
      t.timestamps null: false
    end

    add_index :digital_image_orders, :order_id, name: 'by_order_id'
    add_index :digital_image_orders, :image_id, name: 'by_image_id'
  end
end
