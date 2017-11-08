class AddTotalPagesToItemOrders < ActiveRecord::Migration
  def change
    add_column :item_orders, :total_pages, :integer
  end
end
