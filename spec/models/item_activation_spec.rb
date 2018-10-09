require 'rails_helper'

RSpec.describe Item, type: :model do

  let(:user) { create(:user) }

  let(:order) { create(:order_with_items) }

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
    o = order
    i = o.items.first
    io = ItemOrder.where(order_id: o.id, item_id: i.id).first
    expect(i.active_for_order?(o.id)).to be_truthy
    i.deactivate_for_order(o.id, user.id)
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
    i.deactivate_for_order(o2.id, user.id)
    i.reload
    expect(i.active_order_ids).to eq ([o.id])
  end


  it "deactivates all associated ItemOrders except for specified order" do
    i = create(:item)
    o1 = create(:order)
    o2 = create(:order)
    io1 = ItemOrder.create(item_id: i.id, order_id: o1.id)
    io2 = ItemOrder.create(item_id: i.id, order_id: o2.id)
    i.deactivate_for_other_orders(o1.id, user.id)
    io1.reload
    io2.reload
    expect(io1.active).to be_truthy
    expect(io2.active).to be_falsey
  end

end
