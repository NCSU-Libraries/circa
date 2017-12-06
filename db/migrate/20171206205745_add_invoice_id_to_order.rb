class AddInvoiceIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_id, :string
  end
end
