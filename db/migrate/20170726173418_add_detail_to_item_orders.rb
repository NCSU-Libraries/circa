class AddDetailToItemOrders < ActiveRecord::Migration
  def change
    add_column :item_orders, :detail, :text
  end
end
