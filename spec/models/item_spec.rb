require 'rails_helper'

RSpec.describe Item, type: :model do

  before(:all) do
    populate_roles
    r = UserRole.last
    @u = create(:user, user_role_id: r.id)
  end


  before(:each) do
    DatabaseCleaner.clean_with(:deletion)
    DatabaseCleaner.clean
  end


  it "creates an item from an ArchivesSpace archival object URI" do
    api_values = archivesspace_api_values.first
    archivesspace_uri = api_values[:archival_object_uri]
    items = Item.create_or_update_from_archivesspace(archivesspace_uri)
    expect(items.first).to be_a(Item)
    expect(items.first.resource_title).to eq(api_values[:resource_title])
    expect(items.first.resource_identifier).to eq(api_values[:resource_identifier])
    expect(items.first.resource_uri).to eq(api_values[:resource_uri])
    expect(items.first.uri).to eq(api_values[:item_uri])
    expect(items.first.permanent_location.uri).to eq(api_values[:location_uri])
    expect(items.first.permanent_location.title).to eq(api_values[:location_title])
    expect(items.first.archivesspace_records.include?(archivesspace_uri)).to be true
  end


  it "creates a digital object item from an ArchivesSpace archival object URI" do
    api_values = archivesspace_digital_object_api_values
    archivesspace_uri = api_values[:archival_object_uri]
    items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
    expect(items.first).to be_a(Item)
    expect(items.first.resource_uri).to eq(api_values[:resource_uri])
    expect(items.first.uri).to eq(api_values[:item_uri])
    expect(items.first.digital_object).to be true
  end


  it "creates multiple digital object items from an ArchivesSpace archival object URI" do
    api_values = archivesspace_multiple_digital_object_api_values
    archivesspace_uri = api_values[:archival_object_uri]
    items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
    expect(items.length).to eq(3)
    uris = items.map { |i| i.uri }
    expect(uris).to eq(api_values[:item_uris])
  end


  it "creates multiple item records for the same digital object" do
    api_values = archivesspace_digital_object_api_values
    archivesspace_uri = api_values[:archival_object_uri]
    item1 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
    item2 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
    expect(item1.id).not_to eq(item2.id)
  end


  it "creates a digital object item from an ArchivesSpace component without a digital object" do
    api_values = archivesspace_api_values.first
    archivesspace_uri = api_values[:archival_object_uri]
    items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
    i = items.first
    expect(i).to be_a(Item)
    expect(i.uri).to eq(archivesspace_uri)
    expect(i.unprocessed).to be true
  end


  it "creates an item from a catalog record and item id" do
    item = Item.create_or_update_from_catalog('NCSU2499528', 'S02830408P')
    expect(item.resource_title).to eq("Bridging the gap: public-interest architectural internships")
    expect(item.uri).to eq("/catalog_item/NCSU2499528/S02830408P")
    expect(item.permanent_location.catalog_item_id).to eq('S02830408P')
    expect(item.item_catalog_record).not_to be_nil
  end


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


  it "does not create duplicate items for ArchivesSpace components in same container" do
    item_ids = []
    archivesspace_same_box_api_values.each do |values|
      items = Item.create_or_update_from_archivesspace(values[:archival_object_uri])
      item_ids += items.map { |i| i.id }
    end
    expect(item_ids.length).to be > 1
    expect(item_ids.uniq.length).to eq(1)
  end


  it "aggregates access sessions for digital object items with the same uri" do
    o = create(:order)
    api_values = archivesspace_digital_object_api_values
    archivesspace_uri = api_values[:archival_object_uri]
    item1 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
    item2 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
    create(:access_session, order_id: o.id, item_id: item1.id)
    create(:access_session, order_id: o.id, item_id: item2.id)
    sessions = item1.digital_item_access_sessions
    puts sessions.inspect
    expect(sessions.length).to eq(2)
  end

end
