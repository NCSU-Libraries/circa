class AddClonedOrderIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :cloned_order_id, :integer
  end
end
