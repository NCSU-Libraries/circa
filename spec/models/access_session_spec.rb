require 'rails_helper'

RSpec.describe AccessSession, type: :model do

  before(:all) do
    @u = create(:user)
  end

  it "creates a record and associations" do
    i = create(:item)
    o = create(:order)
    as = AccessSession.create!(item_id: i.id, order_id: o.id)
    expect(as).to be_a(AccessSession)
    as.user_access_sessions.create!(user_id: @u.id)
    as.reload
    expect(as.users.first).to eq(@u)
  end


  it "will not create a new access_session if another is already active" do
    i = create(:item)
    o = create(:order)
    as = AccessSession.create!(item_id: i.id, order_id: o.id)
    as.user_access_sessions.create!(user_id: @u.id)
    as.reload
    expect { AccessSession.create!(item_id: i.id, order_id: o.id) }.to raise_error(CircaExceptions::BadRequest)
    as.close
    expect { AccessSession.create!(item_id: i.id, order_id: o.id) }.not_to raise_error
  end


  it "creates record and user associations in one call" do
    i = create(:item)
    o = create(:order)
    u1 = create(:user)
    u2 = create(:user)
    as = AccessSession.create_with_users(item_id: i.id, order_id: o.id, users: [ u1.attributes, u2.attributes ])
    expect(as).to be_a(AccessSession)
    expect(as.users[0]).to eq(u1)
    expect(as.users[1]).to eq(u2)
  end


  it "tracks active sessions and items in use" do
    i = create(:item)
    o = create(:order)
    as = AccessSession.create_with_users(item_id: i.id, order_id: o.id, users: [ @u.attributes ])
    expect(i.in_use?).to be true
    expect(i.active_access_session.id).to eq(as.id)
  end

end
