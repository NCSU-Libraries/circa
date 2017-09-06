require 'rails_helper'



RSpec.describe DigitalImageOrder, type: :model do

  let(:order) do
    ot = OrderType.create(name: 'test', label: 'test')
    ost = OrderSubType.create(name: 'test', label: 'test', order_type_id: ot.id)
    create(:order, order_sub_type_id: ost.id)
  end

  it "can be associated with an order" do
    dio = create(:digital_image_order, order_id: order.id)
    expect(dio.order).to be_a(Order)
    expect(dio.order.id).to eq(order.id)
  end

end
