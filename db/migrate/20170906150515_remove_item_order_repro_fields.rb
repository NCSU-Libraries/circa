class RemoveItemOrderReproFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :item_orders, :detail
    remove_column :item_orders, :total_pages
  end
end
