require 'rails_helper'

RSpec.describe ItemOrder, type: :model do

  let(:user) { create(:user) }

  let(:order) { create(:order) }

  it "validates uniqueness of association" do
    i = create(:item)
    create(:item_order, item_id: i.id, order_id: order.id)
    expect { create(:item_order, item_id: i.id, order_id: order.id) }.to raise_error
  end

  it "adds new archivesspace_uri to existing record" do
    i = create(:item)
    uri1 = archivesspace_same_box_api_values[0][:archival_object_uri]
    uri2 = archivesspace_same_box_api_values[1][:archival_object_uri]
    item_order = create(:item_order, item_id: i.id, order_id: order.id, archivesspace_uri: [ uri1 ])
    expect(item_order.archivesspace_uri).to eq ( [uri1] )
    item_order.add_archivesspace_uri(uri2)
    expect(item_order.archivesspace_uri).to eq( [uri1,uri2] )
  end


  it "activates and deactivates and records attributes" do
    o = create(:order_with_items)
    i = o.items.first
    io = ItemOrder.where(order_id: o.id, item_id: i.id).last
    expect(io.active).to be_truthy
    io.deactivate(user.id)
    expect(io.active).to be_falsey
    expect(io.deactivated_by_user_id).to eq(user.id)
    io.activate
    expect(io.active).to be_truthy
  end

end
