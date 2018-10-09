class AddTotalPagesToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :total_pages, :integer
  end
end
