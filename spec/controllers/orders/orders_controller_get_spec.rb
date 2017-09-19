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





  describe "GET #index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "redirects to sign_in if user is not logged in" do
      sign_in(nil)
      expect(get :index).to redirect_to('/users/sign_in')
    end


    it "returns response in expected JSON format" do
      create_list(:order, 20)
      get :index, per_page: 5
      expect { JSON.parse response.body }.not_to raise_error
      r = JSON.parse(response.body)
      expect(r['orders'].length).to eq(5)
      expect(r['meta']['pagination']).not_to be_nil
    end

  end




  describe "GET #show" do

    before(:each) do
      get :show, id: @order.id
      @r = JSON.parse(response.body)
    end


    it "returns JSON with http success" do
      expect(response).to have_http_status(:success)
      expect { JSON.parse response.body }.not_to raise_error
    end

    it "returns response in expected JSON format" do
      r = JSON.parse(response.body)
      expect(r['order']['id']).to eq(@order.id)
    end


    it "returns response with 404 when record not found" do
      get :show, id: 'x'
      expect(response).to have_http_status(404)
      r = JSON.parse(response.body)
      expect(r['error']['status']).to eq(404)
    end


    it "includes item_orders in response" do
      expect(@r['order']['item_orders'].length).to eq(1)
      expect(@r['order']['item_orders'][0]['item_id']).to eq(@item.id)
    end


    it "includes digital_image_orders in response" do
      expect(@r['order']['digital_image_orders'].length).to eq(1)
      expect(@r['order']['digital_image_orders'][0]['image_id']).to eq(@digital_image_order.image_id)
    end


    it "includes reproduction_spec in response" do
      expect(@r['order']['item_orders'][0]['reproduction_spec']['id']).to eq(@reproduction_spec.id)
    end


    it "includes order_fees in response" do
      expect(@r['order']['item_orders'][0]['order_fee']['id']).to eq(@order_fee1.id)
      expect(@r['order']['digital_image_orders'][0]['order_fee']['id']).to eq(@order_fee2.id)
    end

  end



end
