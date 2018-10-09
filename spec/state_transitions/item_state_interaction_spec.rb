require 'rails_helper'

RSpec.describe do

  before(:all) do
    populate_roles
  end

  let(:user_role) { UserRole.last }

  let(:user) { create(:user, user_role_id: user_role.id) }

  let(:order_metadata) { transition_metadata(user) }

  let(:shared_item_orders) do
    o1 = create(:order)
    o2 = create(:order)
    i = create(:item)
    io1 = ItemOrder.create!(order_id: o1.id, item_id: i.id)
    io2 = ItemOrder.create!(order_id: o2.id, item_id: i.id)
    o1.trigger!(:confirm, order_metadata)
    o2.trigger!(:confirm, order_metadata)
    io1.reload
    io2.reload
    [io1,io2]
  end

  describe "basic order/item workflow" do

    let(:order) { create(:order_with_items) }

    let(:items) { order.items }

    it "restricts item transfer if order is not confirmed" do
      i = items.first
      available_events = i.available_events_for_order(order.id)
      expect(available_events.index(:transfer)).to be_nil
    end

    it "automatically moves items to ordered when order is confirmed" do
      o = order
      i = items.first
      expect(i.current_state).to eq(i.initial_state)
      o.trigger!(:confirm, order_metadata)
      expect(i.current_state).to eq(:ordered)
    end

    it "allows item transfer after order is confirmed" do
      o = order
      i = items.first
      o.trigger!(:confirm, order_metadata)
      available_events = i.available_events_for_order(o.id)
      expect(available_events.index(:transfer)).to be_a(Integer)
    end

    it "moves order to fulfilled state when all items are on site" do
      o = order
      o.trigger!(:confirm, order_metadata)
      o.items.each do |i|
        move_item_to_ready(i, o, user)
      end
      expect(o.current_state).to eq(:fulfilled)
    end

    it "closes order when its items are returned" do
      o = order
      expect(o.open).to be_truthy
      o.trigger!(:confirm, order_metadata)
      o.items.each do |i|
        move_item_through_all_states(i, o, user)
      end
      o.reload
      expect(o.open).to be_falsey
    end

  end


  describe "behavior of items active on multiple orders" do


    it "can access current active orders" do
      admin = create(:admin_user)
      item_orders = shared_item_orders
      i = item_orders[0].item
      active_orders = i.active_orders
      expect(active_orders.length).to eq(2)
      expect(active_orders[0]).to be_a(Order)
      order1 = item_orders[0].order
      i.deactivate_for_order(order1.id, admin.id)
      order1.reload
      i.reload
      active_orders = i.active_orders
      expect(active_orders.length).to eq(1)
    end


    it "dissallows return event for order if item is active on multiple orders" do
      item_orders = shared_item_orders
      i = item_orders[0].item
      move_item_to_ready(i, item_orders[0].order, user)
      i.trigger!(:already_on_site, transition_metadata(user, item_orders[0].order))
      permitted_events = i.permitted_events
      expect(permitted_events.include?(:mark_for_return)).to be_falsey
      item_orders[0].deactivate(user.id)
      i.reload
      permitted_events = i.permitted_events
      expect(permitted_events.include?(:mark_for_return)).to be_truthy
    end


    it "restricts item return if it is active on multiple orders" do
      item_orders = shared_item_orders
      i = item_orders[0].item
      move_item_to_ready(i, item_orders[0].order, user)
      i_metadata = transition_metadata(user, item_orders[0].order)
      i.trigger!(:already_on_site, i_metadata)
      expect{ i.trigger!(:mark_for_return, i_metadata) }.to raise_error(StateTransitionException::TransitionNotPermitted)
      item_orders[0].deactivate(user.id)
      i.reload
      expect{ i.trigger!(:mark_for_return, i_metadata) }.not_to raise_error
    end


    it "permits return of items on multiple orders if user is admin" do
      admin = create(:admin_user)
      item_orders = shared_item_orders
      i = item_orders[0].item
      i_metadata = transition_metadata(admin, item_orders[0].order)
      move_item_to_ready(i, item_orders[0].order, admin)
      i.trigger!(:already_on_site, i_metadata)
      expect{ i.trigger!(:mark_for_return, i_metadata) }.not_to raise_error
    end


    it "closes order when all of its items are deactivated" do
      o = create(:order_with_items)
      o.trigger!(:confirm, order_metadata)
      o.items.each do |i|
        move_item_to_ready(i, o, user)
      end
      expect(o.open).to be_truthy
      o.items.each do |i|
        i.deactivate_for_order(o.id, user.id)
      end
      o.reload
      expect(o.open).to be_falsey
    end

  end


  # Scenarios only possible when an items returned via admin override
  describe "behavior of items active on multiple orders via admin override" do

    it "deactivates item orders when item is returned" do
      admin = create(:admin_user)
      item_orders = shared_item_orders
      i = item_orders[0].item
      move_item_to_ready(i, item_orders[0].order, user)
      move_item_to_ready(i, item_orders[1].order, admin)
      move_item_from_ready_to_finished(i, item_orders[1].order, admin)
      item_orders[0].reload
      expect(item_orders[0].active).to be_falsey
    end

    it "closes all active orders on item's return when appropriate" do
      admin = create(:admin_user)
      item_orders = shared_item_orders
      o1 = item_orders[0].order
      o2 = item_orders[1].order
      i = item_orders[0].item
      move_item_to_ready(i, o1, user)
      move_item_through_all_states(i, o2, admin)
      o1.reload
      o2.reload
      expect(o1.open).to be_falsey
      expect(o2.open).to be_falsey
    end

  end






end
