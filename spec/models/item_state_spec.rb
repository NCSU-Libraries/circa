require 'rails_helper'

RSpec.describe Item, type: :model do

  before(:each) do
    populate_roles
    @r = UserRole.last
    @u = create(:user, user_role_id: @r.id)
  end

  # before(:each) do
  #   sign_in(@u)
  # end

  it "physical items move between states when specific events are triggered" do
    o = create(:order_with_items)
    i = o.items.first
    o.trigger(:confirm)

    i.trigger(:order)
    expect(i.current_state).to eq(:ordered)

    i.trigger(:transfer)
    expect(i.current_state).to eq(:in_transit_to_temporary_location)

    i.trigger(:receive_at_temporary_location)
    expect(i.current_state).to eq(:arrived_at_temporary_location)

    i.trigger(:prepare_at_temporary_location)
    expect(i.current_state).to eq(:ready_at_temporary_location)

    i.trigger(:check_out)
    expect(i.current_state).to eq(:in_use)

    i.trigger(:check_in)
    expect(i.current_state).to eq(:ready_at_temporary_location)

    i.trigger(:mark_for_return)
    expect(i.current_state).to eq(:to_return)

    i.trigger(:return)
    expect(i.current_state).to eq(:returning_to_permanent_location)

    i.trigger(:receive_at_permanent_location)
    expect(i.current_state).to eq(:at_permanent_location)

  end


  it "digital items move between states when specific events are triggered" do
    o = create(:order_with_digital_item)
    i = o.items.first
    o.trigger(:confirm)

    i.trigger(:order)
    expect(i.current_state).to eq(:ordered)

    i.trigger(:review)
    expect(i.current_state).to eq(:reviewing)

    i.trigger(:prepare_for_use)
    expect(i.current_state).to eq(:preparing_for_use)

    i.trigger(:receive_at_use_location)
    expect(i.current_state).to eq(:ready_at_use_location)

    i.trigger(:check_out)
    expect(i.current_state).to eq(:in_use)

    i.trigger(:check_in)
    expect(i.current_state).to eq(:ready_at_use_location)

    i.trigger(:prepare_for_return)
    expect(i.current_state).to eq(:preparing_for_return)

    i.trigger(:return)
    expect(i.current_state).to eq(:use_complete)
  end


  it "raises StateTransitionExceptions::TransitionNotPermitted if an illegal transition is attempted" do
    o = create(:order_with_items)
    i = o.items.first
    expect { i.trigger! :transfer }.to raise_error(StateTransitionException::TransitionNotPermitted)
  end

end
