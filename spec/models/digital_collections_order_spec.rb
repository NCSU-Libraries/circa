require 'rails_helper'

RSpec.describe DigitalCollectionsOrder, type: :model do

  let(:order) { create(:order) }
  let(:dio) { create(:digital_collections_order, order_id: order.id) }

  it "can be associated with an order" do
    expect(dio.order).to be_a(Order)
    expect(dio.order.id).to eq(order.id)
  end

  it "responds correctly to unit_total" do
    images = dio.requested_images
    expect(dio.unit_total).to eq(images.length)
  end

end
