require 'rails_helper'

RSpec.describe ReproductionSpec, type: :model do

  let(:order) { create(:order) }
  let(:item) { create(:item) }
  let(:item_order) { create(:item_order, order_id: order.id, item_id: item.id) }
  let(:reproduction_spec) { create(:reproduction_spec, item_order: item_order, pages: 7) }

  it "is associated with an order and an item_order" do
    expect(reproduction_spec.item_order).to be_a(ItemOrder)
    expect(reproduction_spec.item_order.id).to eq(item_order.id)
  end

  it "is associated with an item" do
    expect(reproduction_spec.item).to be_a(Item)
    expect(reproduction_spec.item.id).to eq(item.id)
  end

  it "responds correctly to unit_total" do
    expect(reproduction_spec.unit_total).to eq(reproduction_spec.pages)
  end

end
