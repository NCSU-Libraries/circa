require 'rails_helper'

RSpec.describe ItemOrder, type: :model do

  it "validates uniqueness of association" do
    o = create(:order)
    i = create(:item)
    create(:item_order, item_id: i.id, order_id: o.id)
    expect { create(:item_order, item_id: i.id, order_id: o.id) }.to raise_error
  end

  it "adds new archivesspace_uri to existing record" do
    o = create(:order)
    i = create(:item)
    uri1 = archivesspace_same_box_api_values[0][:archival_object_uri]
    uri2 = archivesspace_same_box_api_values[1][:archival_object_uri]
    item_order = create(:item_order, item_id: i.id, order_id: o.id, archivesspace_uri: [ uri1 ])
    expect(item_order.archivesspace_uri).to eq ( [uri1] )
    item_order.add_archivesspace_uri(uri2)
    expect(item_order.archivesspace_uri).to eq( [uri1,uri2] )
  end


  it "activates and deactivates" do
    o = create(:order_with_items)
    o2 = create(:order)
    i = o.items.first
    o2.add_item(i)
    io1 = ItemOrder.where(order_id: o.id, item_id: i.id).first
    io2 = ItemOrder.where(order_id: o2.id, item_id: i.id).first
    expect(io1.active).to be_truthy
    expect(io2.active).to be_truthy
    i.deactivate_for_order(o.id)
    io1.reload
    expect(io1.active).to be_falsey
    expect(io2.active).to be_truthy
  end

end
