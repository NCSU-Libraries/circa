require 'rails_helper'

RSpec.describe UserRole, type: :model do

  # before(:each) do
  #   DatabaseCleaner.clean_with(:deletion)
  #   DatabaseCleaner.clean
  # end

  it "returns the lowest role" do
    DatabaseCleaner.clean_with(:deletion)
    create(:user_role, level: 10)
    create(:user_role, level: 20)
    r = create(:user_role, level: 30)
    role = UserRole.lowest
    expect(role.name).to eq(r.name)
  end


  it "merges user roles" do
    r1 = create(:user_role, level: 10)
    r2 = create(:user_role, level: 20)
    u1 = create(:user, user_role_id: r1.id)
    u2 = create(:user, user_role_id: r2.id)
    UserRole.merge(r1.id, r2.id)
    u1.reload
    expect(u1.user_role_id).to eq(r2.id)
    expect(u2.user_role_id).to eq(r2.id)
  end


  # it "cannot merge from or into admin user role" do
  #   r = create(:user_role)
  #   admin = create(:user_role, name: 'admin', level: 1)
  # end


  it "cannot be destroyed if it has associated users" do
    r1 = create(:user_role, level: 10)
    r2 = create(:user_role, level: 20)
    create(:user, user_role_id: r1.id)
    expect(r1.deletable?).to be_falsey
    expect(r2.deletable?).to be_truthy
  end

end
