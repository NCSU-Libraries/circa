class CreateInvoices < ActiveRecord::Migration[5.2]
  def up
    create_table :invoices do |t|
      t.integer :order_id
      t.date :invoice_date
      t.date :payment_date
      t.text :attn
      t.string :invoice_id
      t.text :custom_to
      t.timestamps
    end

    # migrate fields from orders:
    Order.where('invoice_id IS NOT NULL').find_each do |o|
      Invoice.create!(
        order_id: o.id,
        invoice_date: o.invoice_date,
        payment_date: o.invoice_payment_date,
        attn: o.invoice_attn,
        invoice_id: o.invoice_id
      )
    end

    remove_column :orders, :invoice_date
    remove_column :orders, :invoice_payment_date
    remove_column :orders, :invoice_attn
    remove_column :orders, :invoice_id
  end


  def down
    add_column :orders, :invoice_date, :date
    add_column :orders, :invoice_payment_date, :date
    add_column :orders, :invoice_attn, :string
    add_column :orders, :invoice_id, :string

    Invoice.find_each do |i|
      order = Order.find i.order_id
      order.update_attributes(
        invoice_date: i.invoice_date,
        invoice_payment_date: i.payment_date,
        invoice_attn: i.attn,
        invoice_id: i.invoice_id
      )
    end

    drop_table :invoices
  end

end
