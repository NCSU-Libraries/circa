class AddInvoiceIdToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :invoice_id, :string
  end
end
