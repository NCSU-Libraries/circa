class OrdersAddInvoicePaymentDate < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_payment_date, :date
  end
end
