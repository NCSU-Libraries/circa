class UpdateOrderFees < ActiveRecord::Migration[5.2]
  def change
    add_column :order_fees, :per_order_fee_description, :string
  end
end
