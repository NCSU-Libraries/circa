require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  before(:all) do
    populate_roles
    @order = create(:order)
    @item = create(:item)
    @item_order = create(:item_order, order_id: @order.id, item_id: @item.id)
    @digital_collections_order = create(:digital_collections_order, order_id: @order.id)
    @reproduction_format = create(:reproduction_format)
    @reproduction_spec = create(:reproduction_spec, item_order_id: @item_order.id)
    @order_fee1 = create(:order_fee, record_type: 'ItemOrder', record_id: @item_order.id)
    @order_fee2 = create(:order_fee, record_type: 'DigitalCollectionsOrder', record_id: @digital_collections_order.id)
    @item_order.reload
    @digital_collections_order.reload
    @order.reload
  end

  let(:user) { create(:user) }

  before(:each) do
    sign_in(user)
  end


  describe "DELETE #destroy" do
    it "returns http ok" do
      o = create(:order)
      id = o.id
      delete :destroy, params: { id: o.id }
      expect(response).to have_http_status(:ok)
      get :show, params: { id: id }
      expect(response).to have_http_status(400)
    end
  end

end
