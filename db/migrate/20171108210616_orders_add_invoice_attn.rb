class OrdersAddInvoiceAttn < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_attn, :string
  end
end
