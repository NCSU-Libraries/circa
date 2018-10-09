class AddDeactivateFieldsToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :deactivated_by_user_id, :integer
    add_column :item_orders, :deactivated_at, :datetime

    ItemOrder.find_each do |io|
      deactivated = io.updated_at
      io.update_columns(deactivated_at: deactivated)
    end
  end
end
