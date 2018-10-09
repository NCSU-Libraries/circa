require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    DatabaseCleaner.clean_with(:deletion)
    DatabaseCleaner.clean
    @role = create(:user_role)
  end

  it "should have orders" do
    u = create(:user_with_orders, user_role_id: @role.id)
    u.reload
    expect(u.orders.first).to be_a(Order)
  end


  it "should have assigned orders" do
    u = create(:user_with_assigned_orders, user_role_id: @role.id)
    expect(u.assigned_orders.first).to be_a(Order)
  end


  it "should have notes" do
    u = create(:user, user_role_id: @role.id)
    note_content = "There's a great big beautiful tomorrow"
    u.notes.build(content: note_content)
    u.save
    expect(u.notes.first.content).to eq(note_content)
  end


  it "should keep version on name change" do
     u = create(:user, user_role_id: @role.id)
     u.first_name = "J'bron"
     u.save
     v = u.paper_trail.previous_version
     expect(v.first_name).to eq("Don")
     expect(u.first_name).to eq("J'bron")
  end


  it "has a user_role" do
    u = create(:user, user_role_id: @role.id)
    expect(u.user_role).to eq (@role)
  end


  it "can assign roles with higher level values only" do
    role1 = create(:user_role, level: 2)
    role2 = create(:user_role, level: 3)
    role3 = create(:user_role, level: 4)
    u = create(:user, user_role_id: role2.id)
    assignable_role_ids = u.assignable_roles.map { |r| r.id }
    expect(assignable_role_ids.include?(role1.id)).to be_falsey
    expect(assignable_role_ids.include?(role2.id)).to be_truthy
    expect(assignable_role_ids.include?(role3.id)).to be_truthy
  end

end
