class AddReproductionPagesToItemOrders < ActiveRecord::Migration
  def change
    add_column :item_orders, :reproduction_pages, :integer
  end
end
