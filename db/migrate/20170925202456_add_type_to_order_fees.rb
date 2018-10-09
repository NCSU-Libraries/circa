class AddTypeToOrderFees < ActiveRecord::Migration[5.2]
  def change

    add_column :order_fees, :unit_fee_type, :string
  end
end
