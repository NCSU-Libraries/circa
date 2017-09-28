require 'rails_helper'

RSpec.describe Order, type: :model do

  let(:order_with_items) { create(:order_with_items) }
  let(:research_order_type) { OrderType.find_by(name: 'research') || create(:order_type, name: 'research') }
  let(:course_reserve_order_sub_type) { OrderSubType.find_by(name: 'course_reserve') ||
    create(:order_sub_type, name: 'course_reserve', order_type_id: research_order_type.id) }
  let(:reproduction_order_type) { OrderType.find_by(name: 'reproduction') || create(:order_type, name: 'reproduction') }
  let(:reproduction_order_sub_type) { create(:order_sub_type, order_type_id: reproduction_order_type.id) }
  let(:course_reserve_order) { create(:order_with_items, order_sub_type_id: course_reserve_order_sub_type.id ) }
  let(:reproduction_order) { create(:order, order_sub_type_id: reproduction_order_sub_type.id) }

  it "calls spawn with no errors" do
    o = create(:order)
    expect { o.spawn }.not_to raise_error
  end


  it "can spawn course reserve" do
    o = course_reserve_order
    create(:course_reserve, course_number: 'uncle', order_id: o.id)
    new_order = o.spawn
    expect(new_order.order_sub_type_id).to eq(course_reserve_order_sub_type.id)
    expect(new_order.course_reserve).not_to be_nil
    expect(new_order.course_reserve.course_number).to eq('uncle')
  end


  it "can spawn order and retain item associations" do
    o = order_with_items
    new_order = o.spawn
    expect(new_order.items.length).to eq(o.items.length)
    expect(new_order.items.first.id).to eq(o.items.first.id)
  end


  it "can spawn order and retain digital image associations" do
    o = reproduction_order
    dio = create(:digital_image_order, order_id: o.id)
    new_order = o.spawn
    expect(new_order.digital_image_orders.length).to eq(o.digital_image_orders.length)
    expect(new_order.digital_image_orders.first.resource_identifier).to eq(dio.resource_identifier)
  end

end
