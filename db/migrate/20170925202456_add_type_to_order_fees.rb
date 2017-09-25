class AddTypeToOrderFees < ActiveRecord::Migration
  def change

    add_column :order_fees, :unit_fee_type, :string
  end
end
