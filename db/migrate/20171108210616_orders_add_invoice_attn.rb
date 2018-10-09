class OrdersAddInvoiceAttn < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :invoice_attn, :string
  end
end
