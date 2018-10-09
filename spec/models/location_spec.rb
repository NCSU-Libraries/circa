require 'rails_helper'

RSpec.describe Location, type: :model do

  it "has permenant items" do
    l = create(:location)
    i = create(:item)
    i.permanent_location_id = l.id
    i.save
    expect(l.permanent_items.first).to eq(i)
  end

  it "has current items" do
    l = create(:location)
    i = create(:item)
    i.current_location_id = l.id
    i.save
    expect(l.current_items.first).to eq(i)
  end

end
