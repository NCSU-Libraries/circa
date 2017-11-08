require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  before(:all) do
    populate_roles
    @order = create(:order)
    @item = create(:item)
    @item_order = create(:item_order, order_id: @order.id, item_id: @item.id)
    @digital_image_order = create(:digital_image_order, order_id: @order.id)
    @reproduction_format = create(:reproduction_format)
    @reproduction_spec = create(:reproduction_spec, item_order_id: @item_order.id)
    @order_fee1 = create(:order_fee, record_type: 'ItemOrder', record_id: @item_order.id)
    @order_fee2 = create(:order_fee, record_type: 'DigitalImageOrder', record_id: @digital_image_order.id)
    @item_order.reload
    @digital_image_order.reload

    puts @digital_image_order.inspect
    puts @item_order.inspect

    @order.reload
  end

  let(:user) { create(:user) }

  before(:each) do
    sign_in(user)
  end


  describe "PUT #update" do

    it "returns http success" do
      o = create(:order)
      new_date = '2020-01-01'
      put :update, id: o.id, order: { access_date_start: new_date }
      expect(response).to have_http_status(:success)
    end

    it "updates record with values from params" do
      o = create(:order)
      new_date = '2020-01-01'
      put :update, id: o.id, order: { access_date_start: new_date }
      o.reload
      expect(o.access_date_start).to eq(Date.parse(new_date))
    end

    it "ignores params values not permitted by safe_attributes without raising an error" do
      o = create(:order)
      expect { put :update, id: o.id, order: { foo: 'boo' } }.not_to raise_error
    end


    describe "update order_type from 'reproduction" do
      let(:order_type) { create(:order_type, name: 'reproduction') }
      let(:order_sub_type) { create(:order_sub_type, order_type_id: order_type.id) }
      let(:other_order_sub_type) { create(:order_sub_type) }
      let(:o) { create(:order, order_sub_type_id: order_sub_type.id) }
      let!(:dio) { create(:digital_image_order, order_id: o.id) }

      it "removes reproduction associations when order-type is changed" do
        order = o.clone
        expect(o.digital_image_orders.length).to eq(1)
        put :update, id: order.id, order: { order_sub_type_id: other_order_sub_type.id }
        order.reload
        expect(o.digital_image_orders.length).to eq(0)
      end
    end

  end


  describe "PUT deactivate_item and PUT activate_item" do
    it "deactivates and reactivates item" do
      o = create(:order_with_items)
      i = o.items.first
      io = o.item_orders.where(item_id: i.id).first
      expect(io.active).to be_truthy
      put :deactivate_item, id: o.id, item_id: i.id
      io.reload
      expect(io.active).to be_falsey
      put :activate_item, id: o.id, item_id: i.id
      io.reload
      expect(io.active).to be_truthy
    end
  end


  describe "state changes" do
    it "changes state according to permitted transitions" do
      o = create(:order)
      event = o.available_events.first
      expect(o.current_state.to_s).to eq(o.initial_state.to_s)
      expect(put :update_state, id: o.id, event: event).to have_http_status(:success)
      expect(put :update_state, id: o.id, event: :foo).to have_http_status(403)
    end
  end



end
