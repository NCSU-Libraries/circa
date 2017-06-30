require 'rails_helper'

RSpec.describe Order, type: :model do

  it "moves between states when specific events are triggered" do
    o = create(:order_with_items)
    o.trigger(:review)
    expect(o.current_state).to eq(:reviewing)
    o.trigger(:confirm)
    expect(o.current_state).to eq(:confirmed)

    options = { order_id: o.id}

    # move items through workflow to ready
    o.items.each do |i|
      i.trigger(:order, options )
      i.trigger(:transfer, options )
      i.trigger(:receive_at_temporary_location, options )
      i.trigger(:prepare_at_temporary_location, options )
    end
    # all items should be ready now, :fulfill triggered automatically
    expect(o.current_state).to eq(:fulfilled)

    # move items through workflow to ready at permanent location
    o.items.each do |i|
      i.trigger(:mark_for_return, options )
      i.trigger(:return, options )
      i.trigger(:receive_at_permanent_location, options )
    end

    # o.trigger(:activate)
    # expect(o.current_state).to eq(:active)
    o.trigger(:finish)

    expect(o.current_state).to eq(:finished)
  end

  it "cannot move between states illegally" do
    o = create(:order)
    event_response = o.trigger(:fulfill)
    expect(event_response).to be_falsey
    o.trigger(:confirm)
    expect { o.trigger!(:activate) }.to raise_error(StateTransitionException::TransitionNotPermitted)
  end


  it "is deletable until items are transferred" do
    o = create(:order_with_items)
    i = o.items.first
    o.trigger!(:confirm)
    i.trigger(:order, { order_id: o.id })
    o.reload
    expect(i.active_order_id).to eq(o.id)
    expect(o.deletable?).to be true
    i.trigger(:transfer, { order_id: o.id })
    o.reload
    expect(o.deletable?).to be false
  end


  it "is only deletable if conditions are met" do
    o1 = create(:order)
    o2 = create(:order)
    i = create(:item)
    ItemOrder.create(item_id: i.id, order_id: o1.id)
    ItemOrder.create(item_id: i.id, order_id: o2.id)
    expect(o1.deletable?).to be true
    expect(o2.deletable?).to be true
    o1.trigger!(:confirm)
    o2.trigger!(:confirm)
    # i.trigger!(:order, { order_id: o1.id })
    i.trigger!(:transfer, { order_id: o1.id })
    expect(i.active_order_id).to eq(o1.id)
    expect(o1.deletable?).to be false
    expect(o2.deletable?).to be true
  end


end
