require 'rails_helper'

RSpec.describe Invoice, type: :model do

  let(:order) { create(:order) }

  let(:invoice) do
    o = create(:order)
    Invoice.create!(order_id: o.id)
  end

  it "validates presence of associated order" do
    bad_order_id = order.id + 1000
    expect { Invoice.create!(order_id: bad_order_id) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "creates invoice associated with order" do
    expect(invoice.order).to be_a(Order)
  end

  it "sets date and assigns invoice id" do
    invoice.set_date_and_id
    invoice.reload
    expect(invoice.invoice_id).to be_a(String)
    expect(invoice.invoice_date).to eq(DateTime.now.to_date)
  end

  it "will generate invoice_id only once after invoice_date is set" do
    expect(invoice.invoice_date).to be_nil
    expect(invoice.invoice_id).to be_nil
    invoice.update_attributes(invoice_date: Date.today)
    expect(invoice.invoice_date).to be_a(Date)
    expect(invoice.invoice_id).to be_a(String)
    iid = invoice.invoice_id.clone
    invoice.update_attributes(invoice_date: Date.tomorrow)
    invoice.reload
    expect(invoice.invoice_id).to eq(iid)
  end

end
