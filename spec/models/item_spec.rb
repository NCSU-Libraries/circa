require 'rails_helper'

RSpec.describe Item, type: :model do

  let(:user) { create(:user) }

  before(:all) do
    populate_roles
    r = UserRole.last
    @u = create(:user, user_role_id: r.id)
  end


  before(:each) do
    DatabaseCleaner.clean_with(:deletion)
    DatabaseCleaner.clean
  end


  # it "creates an item from a catalog record and item id" do
  #   item = Item.create_or_update_from_catalog('NCSU2499528', 'S02830408P')
  #   expect(item.resource_title).to eq("Bridging the gap: public-interest architectural internships")
  #   expect(item.uri).to eq("/catalog_item/NCSU2499528/S02830408P")
  #   expect(item.permanent_location.catalog_item_id).to eq('S02830408P')
  #   expect(item.item_catalog_record).not_to be_nil
  # end


  it "has current location" do
    i = create(:item)
    l = create(:location)
    i.current_location_id = l.id
    i.save
    expect(i.current_location).to eq(l)
  end


  it "has permanent location" do
    i = create(:item)
    l = create(:location)
    i.permanent_location_id = l.id
    i.save
    expect(i.permanent_location).to eq(l)
  end


  it "maintains uniqueness of uri" do
    Item.create(uri: '/repositories/2/resources/23/box/1')
    expect { Item.create!(uri: '/repositories/2/resources/23/box/1') }.to raise_error(ActiveRecord::RecordInvalid)
  end


  it "allows non-unique uri for digital object items" do
    Item.create(uri: '/repositories/2/resources/23/box/1')
    expect { Item.create!(digital_object: true, uri: '/repositories/2/resources/23/box/1') }.not_to raise_error
  end


  pending "aggregates access sessions for digital object items with the same uri"

  # TODO replace test below with static data
  # it "aggregates access sessions for digital object items with the same uri" do
  #   o = create(:order)
  #   api_values = archivesspace_digital_object_api_values
  #   archivesspace_uri = api_values[:archival_object_uri]
  #   item1 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
  #   item2 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
  #   create(:access_session, order_id: o.id, item_id: item1.id)
  #   create(:access_session, order_id: o.id, item_id: item2.id)
  #   sessions = item1.digital_item_access_sessions
  #   expect(sessions.length).to eq(2)
  # end

end
