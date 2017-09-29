class AddClonedOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cloned_order_id, :integer
  end
end
