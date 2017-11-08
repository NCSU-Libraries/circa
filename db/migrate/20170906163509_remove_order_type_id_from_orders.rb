class RemoveOrderTypeIdFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :order_type_id
  end
end
