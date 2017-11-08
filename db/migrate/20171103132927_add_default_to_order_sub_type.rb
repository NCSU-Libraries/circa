class AddDefaultToOrderSubType < ActiveRecord::Migration
  def change
    add_column :order_sub_types, :default, :boolean
  end
end
