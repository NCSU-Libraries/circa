require 'rails_helper'

RSpec.describe Enumeration, type: :model do

  # merge
  # it "merges order_type values" do
  #   e = Enumeration.create(name: 'order_type')
  #   ev1 = EnumerationValue.create(enumeration_id: e.id, value: 'research1')
  #   ev2 = EnumerationValue.create(enumeration_id: e.id, value: 'research2')
  #   o1 = create(:order, order_type_id: ev1.id)
  #   o2 = create(:order, order_type_id: ev2.id)
  #   expect(o1.order_type_id).not_to eq(o2.order_type_id)
  #   Enumeration.merge_values(ev1.id, ev2.id, 'order_type')
  #   o1.reload
  #   o2.reload
  #   expect(o1.order_type_id).to eq(o2.order_type_id)
  # end

  it "merges location_source values" do
    e = Enumeration.create(name: 'location_source')
    ev1 = EnumerationValue.create(enumeration_id: e.id, value: 'source1')
    ev2 = EnumerationValue.create(enumeration_id: e.id, value: 'source2')
    l1 = create(:location, source_id: ev1.id)
    l2 = create(:location, source_id: ev2.id)
    expect(l1.source_id).not_to eq(l2.source_id)
    Enumeration.merge_values(ev1.id, ev2.id, 'location_source')
    l1.reload
    l2.reload
    expect(l1.source_id).to eq(l2.source_id)
  end

  it "merges researcher_type values" do
    role = create(:user_role)
    e = Enumeration.create(name: 'researcher_type')
    ev1 = EnumerationValue.create(enumeration_id: e.id, value: 'type1')
    ev2 = EnumerationValue.create(enumeration_id: e.id, value: 'type2')
    u1 = create(:user, researcher_type_id: ev1.id, user_role_id: role.id)
    u2 = create(:user, researcher_type_id: ev2.id, user_role_id: role.id)
    expect(u1.researcher_type_id).not_to eq(u2.researcher_type_id)
    Enumeration.merge_values(ev1.id, ev2.id, 'researcher_type')
    u1.reload
    u2.reload
    expect(u1.researcher_type_id).to eq(u2.researcher_type_id)
  end

  # values by enumeration name

end
