require 'rails_helper'

RSpec.describe Order, type: :model do

  before(:all) do
    populate_roles
  end

  let(:user_role) { UserRole.last }

  let(:user) { create(:user, user_role_id: user_role.id) }

  let(:order_metadata) { transition_metadata(user) }


  it "cannot move between states illegally" do
    o = create(:order)
    event_response = o.trigger(:fulfill, order_metadata)
    expect(event_response).to be_falsey
    o.trigger(:confirm, order_metadata)
    expect { o.trigger!(:activate, order_metadata) }.to raise_error(StateTransitionException::TransitionNotPermitted)
  end


  it "is deletable until items are transferred" do
    o = create(:order_with_items)
    i = o.items.first
    item_metadata = transition_metadata(user, o)

    o.trigger!(:confirm, order_metadata)
    i.trigger(:order, item_metadata)
    o.reload
    expect(i.active_order_id).to eq(o.id)
    expect(o.deletable?).to be true
    i.trigger(:transfer, item_metadata)
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

    o1.trigger!(:confirm, order_metadata)
    o2.trigger!(:confirm, order_metadata)
    # i.trigger!(:order, { order_id: o1.id })
    i.trigger!(:transfer, transition_metadata(user, o1))

    expect(i.active_order_id).to eq(o1.id)
    expect(o1.deletable?).to be false
    expect(o2.deletable?).to be true
  end


end
