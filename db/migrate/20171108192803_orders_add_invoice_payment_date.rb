class OrdersAddInvoicePaymentDate < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :invoice_payment_date, :date
  end
end
