require 'rails_helper'

RSpec.describe Item, type: :model do

  # it "has a single active order with which it is associated" do
  #   o = create(:order_with_items)
  #   i = o.items.first
  #   o2 = create(:order)
  #   ItemOrder.create!(item_id: i.id, order_id: o2.id)
  #   expect(i.active_order_id).to eq(o.id)
  # end


  # it "updates the active order with which it is associated" do
  #   o = create(:order_with_items)
  #   i = o.items.first
  #   o2 = create(:order)
  #   ItemOrder.create!(item_id: i.id, order_id: o2.id)
  #   expect(i.active_order_id).to eq(o.id)
  #   i.change_active_order_id(o2.id)
  #   expect(i.active_order_id).to eq(o2.id)
  # end

  it "can deactivate, reactivate and verify activation for an order" do
    o = create(:order_with_items)
    o2 = create(:order)
    i = o.items.first
    expect(i.active_for_order?(o.id)).to be_truthy
    expect(i.active_for_order?(o2.id)).to be_falsey
    i.deactivate_for_order(o.id)
    expect(i.active_for_order?(o.id)).to be_falsey
    i.activate_for_order(o.id)
    expect(i.active_for_order?(o.id)).to be_truthy
  end

  it "recalls ids for orders on which item is active" do
    o = create(:order_with_items)
    i = o.items.first
    o2 = create(:order)
    ItemOrder.create(item_id: i.id, order_id: o2.id)
    expect(i.active_order_ids).to eq ([o.id, o2.id])
    i.deactivate_for_order(o2.id)
    i.reload
    expect(i.active_order_ids).to eq ([o.id])
  end

end
