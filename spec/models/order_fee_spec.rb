require 'rails_helper'

RSpec.describe OrderFee, type: :model do

  let(:item_order) { create(:item_order) }
  let(:reproduction_spec) { create(:reproduction_spec, item_order: item_order, pages: 3) }
  let(:dio) { create(:digital_image_order, requested_images: [ 'a','b','c']) }

  it "can be associated with an item_order" do
    order_fee = create(:order_fee, record_id: item_order.id, record_type: 'ItemOrder')
    expect(order_fee.record).to be_a(ItemOrder)
    expect(order_fee.record.id).to eq(item_order.id)
  end


  it "can be associated with a digital_image_order" do
    order_fee = create(:order_fee, record_id: dio.id, record_type: 'DigitalImageOrder')
    expect(order_fee.record).to be_a(DigitalImageOrder)
    expect(order_fee.record.id).to eq(dio.id)
  end


  it "can calculate a total for an associated digital_image_order" do
    order_fee = create(:order_fee, record_id: dio.id, record_type: 'DigitalImageOrder',
      per_unit_fee: 2.50, per_order_fee: 2.50)
    expect(order_fee.total).to eq(10.00)
  end


  it "can calculate a total for an associated item_order" do
    order_fee = create(:order_fee, record_id: item_order.id, record_type: 'ItemOrder',
      per_unit_fee: 2.50, per_order_fee: 2.50)
    reproduction_spec.item_order.reload
    expect(order_fee.total).to eq(10.00)
  end

end
