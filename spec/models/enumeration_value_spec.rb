require 'rails_helper'

RSpec.describe EnumerationValue, type: :model do

  # pending "add some examples to (or delete) #{__FILE__}"

  # it "cannot delete an order_type value that is in use" do
  #   e = Enumeration.create(name: 'order_type')
  #   ev = EnumerationValue.create(enumeration_id: e.id, value: 'research')
  #   create(:order, order_type_id: ev.id)
  #   expect(ev.deletable?).to be_falsey
  # end

  it "cannot delete a location_source value that is in use" do
    e = Enumeration.create(name: 'location_source')
    ev = EnumerationValue.create(enumeration_id: e.id, value: 'circa')
    create(:location, source_id: ev.id)
    expect(ev.deletable?).to be_falsey
  end

  it "cannot delete a researcher_type value that is in use" do
    role = create(:user_role)
    e = Enumeration.create(name: 'researcher_type')
    ev = EnumerationValue.create(enumeration_id: e.id, value: 'researcher')
    create(:user, researcher_type_id: ev.id, user_role_id: role.id)
    expect(ev.deletable?).to be_falsey
  end

  it "can delete a value that is not in use" do
    e = Enumeration.create(name: 'researcher_type')
    ev = EnumerationValue.create(enumeration_id: e.id, value: 'researcher')
    expect(ev.deletable?).to be_truthy
  end

  # it "raises error when trying to destroy a value that is in use" do
  #   e = Enumeration.create(name: 'order_type')
  #   ev = EnumerationValue.create(enumeration_id: e.id, value: 'research')
  #   create(:order, order_type_id: ev.id)
  #   expect { ev.destroy! }.to raise_error
  # end

  it "can retrieve the name of its associated enumeration" do
    e = Enumeration.create(name: 'order_type')
    ev = EnumerationValue.create(enumeration_id: e.id, value: 'research')
    expect(ev.enumeration_name).to eq('order_type')
  end

end
