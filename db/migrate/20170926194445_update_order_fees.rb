class UpdateOrderFees < ActiveRecord::Migration
  def change
    add_column :order_fees, :per_order_fee_description, :string
  end
end
