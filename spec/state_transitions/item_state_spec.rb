require 'rails_helper'

RSpec.describe Item, type: :model do

  before(:all) do
    populate_roles
  end

  let(:user_role) { UserRole.last }

  let(:user) { create(:user, user_role_id: user_role.id) }


  it "physical items move between states when specific events are triggered" do
    o = create(:order_with_items)
    i = o.items.first
    i_metadata = transition_metadata(user, o)
    o_metadata = transition_metadata(user)

    o.trigger(:confirm, o_metadata)

    i.trigger(:order, i_metadata)
    expect(i.current_state).to eq(:ordered)

    i.trigger(:transfer, i_metadata)
    expect(i.current_state).to eq(:in_transit_to_temporary_location)

    i.trigger(:receive_at_temporary_location, i_metadata)
    expect(i.current_state).to eq(:arrived_at_temporary_location)

    i.trigger(:prepare_at_temporary_location, i_metadata)
    expect(i.current_state).to eq(:ready_at_temporary_location)

    i.trigger(:check_out, i_metadata)
    expect(i.current_state).to eq(:in_use)

    i.trigger(:check_in, i_metadata)
    expect(i.current_state).to eq(:ready_at_temporary_location)

    i.trigger(:mark_for_return, i_metadata)
    expect(i.current_state).to eq(:to_return)

    i.trigger(:return, i_metadata)
    expect(i.current_state).to eq(:returning_to_permanent_location)

    i.trigger(:receive_at_permanent_location, i_metadata)
    expect(i.current_state).to eq(:at_permanent_location)

  end


  it "digital items move between states when specific events are triggered" do
    o = create(:order_with_digital_item)
    i = o.items.first
    i_metadata = transition_metadata(user, o)
    o_metadata = transition_metadata(user)

    o.trigger(:confirm, o_metadata)

    i.trigger(:order, i_metadata)
    expect(i.current_state).to eq(:ordered)

    i.trigger(:review, i_metadata)
    expect(i.current_state).to eq(:reviewing)

    i.trigger(:prepare_for_use, i_metadata)
    expect(i.current_state).to eq(:preparing_for_use)

    i.trigger(:receive_at_use_location, i_metadata)
    expect(i.current_state).to eq(:ready_at_use_location)

    i.trigger(:check_out, i_metadata)
    expect(i.current_state).to eq(:in_use)

    i.trigger(:check_in, i_metadata)
    expect(i.current_state).to eq(:ready_at_use_location)

    i.trigger(:prepare_for_return, i_metadata)
    expect(i.current_state).to eq(:preparing_for_return)

    i.trigger(:return, i_metadata)
    expect(i.current_state).to eq(:use_complete)
  end


  it "raises StateTransitionExceptions::TransitionNotPermitted if an illegal transition is attempted" do
    o = create(:order_with_items)
    i = o.items.first
    i_metadata = transition_metadata(user, o)
    expect { i.trigger!(:transfer, i_metadata) }.to raise_error(StateTransitionException::TransitionNotPermitted)
  end

end
