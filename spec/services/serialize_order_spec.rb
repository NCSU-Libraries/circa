require 'rails_helper'

RSpec.describe do

  let(:order) { create(:order_with_items) }

  it "does not raise exception" do
    expect { SerializeOrder.call(order) }.not_to raise_error
  end

  let(:response) { SerializeOrder.call(order) }

  it "returns a hash of record attributes" do
    expect(response).to be_a(Hash)
  end

  it "serializes attributes correctly" do
    expect(response[:order][:id]).to eq(order.id)
    expect(response[:order][:order_type_id]).to eq(order.order_type_id)
  end

  it "formats dates as string" do
    expect(response[:order][:created_at]).to be_a(String)
  end

  it "serializes associated item_orders" do
    expect(response[:order][:item_orders]).to be_a(Array)
    expect(response[:order][:item_orders].length).to eq (order.item_orders.length)
  end

  it "serializes temporary location" do
    expect(response[:order][:temporary_location][:id]).to eq(order.temporary_location.id)
  end

end
