class AddRemoteToOrderUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :order_users, :remote, :boolean
  end
end
