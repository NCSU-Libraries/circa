class AddDefaultLocationIdToOrderSubTypes < ActiveRecord::Migration
  def change
    add_column :order_sub_types, :default_location_id, :integer
  end
end
