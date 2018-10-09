class AddInvoiceDateToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :invoice_date, :date
  end
end
