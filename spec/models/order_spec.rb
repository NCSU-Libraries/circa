require 'rails_helper'

RSpec.describe Order, type: :model do

  let(:order) { create(:order) }
  let(:u) { create(:user) }
  let(:order_with_user_and_assignee) { create(:order_with_user_and_assignee) }
  let(:order_with_items) { create(:order_with_items) }

  before(:each) do
    populate_roles
    @u = create(:user)
  end


  it "should have user" do
    expect(order_with_user_and_assignee.users.first).to be_a(User)
  end


  it "should have assigned user" do
    expect(order_with_user_and_assignee.assignees.first).to be_a(User)
  end


  it "should have items" do
    expect(order_with_items.items.first).to be_a(Item)
  end


  it "should have notes" do
    note_content = "There's a great big beautiful tomorrow"
    order.notes.build(content: note_content)
    order.save
    expect(order.notes.first.content).to eq(note_content)
  end


  it "provides an array of associated item ids" do
    items = order.items
    expect(order.item_ids).to eq(items.map { |i| i.id })
  end


  it "can recall version of user data from time of request" do
    o = create(:order_with_user_and_assignee)
    p = o.users.first
    o.paper_trail.touch_with_version
    sleep 1
    p.update_attributes(first_name: 'Donna')
    o.reload
    v = o.paper_trail.previous_version
    expect(o.users.first.first_name).to eq('Donna')
    expect(v.version_users.first.first_name).to eq('Don')
  end


  it "can recall items associated with previous version" do
    o = order_with_items.clone
    first_item_id = o.items.first.id
    o.paper_trail.touch_with_version
    o.item_orders.first.destroy
    o.reload
    current_item_ids = o.item_ids
    previous_item_ids = o.paper_trail.previous_version.version.association_data[:item_ids]
    expect(current_item_ids.include?(first_item_id)).to be false
    expect(previous_item_ids.include?(first_item_id)).to be true
  end


  it "can be reassigned" do
    o = create(:order_with_user_and_assignee)
    old_assignee = o.assignees.first
    new_assignee = create(:user, first_name: 'Alfred', last_name: 'Apaka')
    o.reassign_to(new_assignee.id)
    o.reload
    expect(o.assignee_ids.include?(new_assignee.id)).to be true
    expect(o.assignee_ids.include?(old_assignee.id)).to be false
  end


  it "maintains previous assignments in version" do
    o = create(:order_with_user_and_assignee)
    old_assignee = o.assignees.first
    new_assignee = create(:user, first_name: 'Alfred', last_name: 'Apaka')
    o.reassign_to(new_assignee.id)
    vo = o.paper_trail.previous_version
    expect(vo.version_assignees.include?(new_assignee)).to be false
    expect(vo.version_assignees.include?(old_assignee)).to be true
  end




  it "will not add duplicate items" do
    o = create(:order)
    i = create(:item)
    add1 = o.add_item(i)
    add2 = o.add_item(i)
    expect(add1).to be_a(ItemOrder)
    expect(add2).to eq(add1)
  end



  it "adds items created from ArchivesSpace URIs" do
    o = create(:order)
    as_values = archivesspace_api_values.first
    as_uri = as_values[:archival_object_uri]
    o.add_items_from_archivesspace(as_uri)
    o.reload
    item = Item.where(uri: as_values[:item_uri]).first
    expect(o.item_ids.include?(item.id)).to be true
    expect(o.archivesspace_records.include?(as_uri)).to be true
  end


  it "returns user that created the order" do
    o = create(:order_with_user_and_assignee)
    o.versions.each { |v| v.update_attributes(whodunnit: @u.id) }
    u1 = o.created_by_user
    expect(u1).to be_a(User)
    u2 = o.last_updated_by_user
    expect(u2).to be_a(User)
  end


  it "aggregates fees for reproduction" do
    o = create(:order)
    create(:item_order, order_id: o.id)
    create(:digital_image_order, order_id: o.id)
    create(:order_fee, record_type: 'ItemOrder', record_id: item_order.id)
    create(:order_fee, record_type: 'DigitalImageOrder', record_id: digital_image_order.id)
    order_fees = o.order_fees
    expect(order_fees).to be_a(Array)
    expect(order_fees.length).to eq(2)
    expect(order_fees.first).to be_a(OrderFee)
  end

end
