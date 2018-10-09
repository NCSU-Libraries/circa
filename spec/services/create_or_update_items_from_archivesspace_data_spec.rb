require 'rails_helper'

RSpec.describe do

  pending "creates a digital object item from an ArchivesSpace archival object URI"

  # OLD TEST REMOVED FROM ORDER SPEC
  # it "creates a digital object item from an ArchivesSpace archival object URI" do
  #   api_values = archivesspace_digital_object_api_values
  #   archivesspace_uri = api_values[:archival_object_uri]
  #   items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
  #   expect(items.first).to be_a(Item)
  #   expect(items.first.resource_uri).to eq(api_values[:resource_uri])
  #   expect(items.first.uri).to eq(api_values[:item_uri])
  #   expect(items.first.digital_object).to be true
  # end

  pending "creates multiple digital object items from an ArchivesSpace archival object URI"

  # OLD TEST REMOVED FROM ORDER SPEC
  # it "creates multiple digital object items from an ArchivesSpace archival object URI" do
  #   api_values = archivesspace_multiple_digital_object_api_values
  #   archivesspace_uri = api_values[:archival_object_uri]
  #   items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
  #   expect(items.length).to eq(3)
  #   uris = items.map { |i| i.uri }
  #   expect(uris).to eq(api_values[:item_uris])
  # end

  pending "creates multiple item records for the same digital object"

  # OLD TEST REMOVED FROM ORDER SPEC
  # it "creates multiple item records for the same digital object" do
  #   api_values = archivesspace_digital_object_api_values
  #   archivesspace_uri = api_values[:archival_object_uri]
  #   item1 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
  #   item2 = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })[0]
  #   expect(item1.id).not_to eq(item2.id)
  # end

  pending "creates a digital object item from an ArchivesSpace component without a digital object"

  # OLD TEST REMOVED FROM ORDER SPEC
  # it "creates a digital object item from an ArchivesSpace component without a digital object" do
  #   api_values = archivesspace_api_values.first
  #   archivesspace_uri = api_values[:archival_object_uri]
  #   items = Item.create_or_update_from_archivesspace(archivesspace_uri, { digital_object: true })
  #   i = items.first
  #   expect(i).to be_a(Item)
  #   expect(i.uri).to eq(archivesspace_uri)
  #   expect(i.unprocessed).to be true
  # end


  # it "does not create duplicate items for ArchivesSpace components in same container" do
  #   item_ids = []
  #   archivesspace_same_box_api_values.each do |values|
  #     items = Item.create_or_update_from_archivesspace(values[:archival_object_uri])
  #     item_ids += items.map { |i| i.id }
  #   end
  #   expect(item_ids.length).to be > 1
  #   expect(item_ids.uniq.length).to eq(1)
  # end

end
