class AddDetailToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :detail, :text
  end
end
