class AddDefaultLocationIdToOrderSubTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :order_sub_types, :default_location_id, :integer
  end
end
