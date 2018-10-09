class AddDefaultToOrderSubType < ActiveRecord::Migration[5.2]
  def change
    add_column :order_sub_types, :default, :boolean
  end
end
