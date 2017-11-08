class AddInvoiceDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_date, :date
  end
end
