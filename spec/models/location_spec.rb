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

  it "creates item from catalog data" do
    data = catalog_request_item
    location = Location.create_or_update_from_catalog_item(data)
    expect(location).to be_a(Location)
    expect(location.catalog_item_id).to eq(data[:barcode])
    location2 = Location.create_or_update_from_catalog_item(data)
    expect(location2.id).to eq(location.id)
  end

end
