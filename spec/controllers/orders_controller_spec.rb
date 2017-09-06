require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  DatabaseCleaner.start

  before(:each) do
    populate_roles
    r = UserRole.last
    @u = create(:user, user_role_id: r.id)
  end


  describe "GET #index" do

    it "returns http success" do
      sign_in(@u)
      get :index
      expect(response).to have_http_status(:success)
    end

    it "redirects to sign_in if user is not logged in" do
      sign_in(nil)
      expect(get :index).to redirect_to('/users/sign_in')
    end


    it "returns response in expected JSON format" do
      DatabaseCleaner.clean
      sign_in(@u)
      orders = create_list(:order, 20)
      get :index, per_page: 5
      expect { JSON.parse response.body }.not_to raise_error
      r = JSON.parse(response.body)
      expect(r['orders'].length).to eq(5)
      expect(r['meta']['pagination']).not_to be_nil
    end

  end


  describe "GET #show" do

    it "returns JSON with http success" do
      sign_in(@u)
      o = create(:order)
      get :show, id: o.id
      expect(response).to have_http_status(:success)
      expect { JSON.parse response.body }.not_to raise_error
    end

    it "returns response in expected JSON format" do
      sign_in(@u)
      o = create(:order)
      get :show, id: o.id
      r = JSON.parse(response.body)
      expect(r['order']['id']).to eq(o.id)
    end


    it "returns response with 404 when record not found" do
      sign_in(@u)
      get :show, id: 'x'
      expect(response).to have_http_status(404)
      r = JSON.parse(response.body)
      expect(r['error']['status']).to eq(404)
    end

  end


  describe "POST #create" do

    let(:user_role) { UserRole.last }
    let(:user) { create(:user, user_role_id: user_role.id) }
    let(:api_values) { archivesspace_api_values.first }
    let(:archivesspace_uri) { api_values[:archival_object_uri] }
    let(:location) { create(:location) }
    let(:order_type) { OrderType.create(name: 'test', label: 'test') }
    let(:order_sub_type) { OrderSubType.create(name: 'test', label: 'test', order_type_id: order_type.id) }

    let(:item_orders) do
      item_records = create_list(:item, 3)
      item_orders = []
      item_records.each do |i|
        item_order = { item_id: i.id, archivesspace_uri: [ archivesspace_uri ] }
        item_orders << item_order
      end
      item_orders
    end

    let(:digital_image_orders_data) do
      [
        { image_id: "image1", requested_images: [ 'imagefile1-1', 'imagefile1-2' ] },
        { image_id: "image2", requested_images: [ 'imagefile2-1', 'imagefile2-2' ] },
      ]
    end

    let(:order_post_data) do
      {
        users: [ user.attributes ],
        temporary_location: { id: location.id },
        primary_user_id: user.id,
        order_type_id: order_type.id,
        order_sub_type_id: order_sub_type.id
      }
    end

    it "creates order, and adds items and users, and returns json response with http success" do
      sign_in(@u)
      order_data = order_post_data
      order_data[:item_orders] = item_orders
      post :create, order: order_data
      expect(response).to have_http_status(:success)
      expect { JSON.parse response.body }.not_to raise_error
      expect(JSON.parse(response.body)['order']['item_orders'].empty?).not_to be true
      expect(assigns(:order).archivesspace_records.include?(archivesspace_uri)).to be true
      expect(JSON.parse(response.body)['order']['users'].empty?).not_to be true
      expect(JSON.parse(response.body)['order']['primary_user_id']).to eq(user.id)
    end

    it "creates reproduction order with digital images" do
      sign_in(@u)
      order_data = order_post_data
      order_data[:digital_image_orders] = digital_image_orders_data
      post :create, order: order_data
      expect(JSON.parse(response.body)['order']['digital_image_orders'].empty?).not_to be true
      expect(JSON.parse(response.body)['order']['digital_image_orders'].length).to eq(2)
    end

  end


  describe "PUT #update" do

    it "returns http success" do
      sign_in(@u)
      o = create(:order)
      new_date = '2020-01-01'
      put :update, id: o.id, order: { access_date_start: new_date }
      expect(response).to have_http_status(:success)
    end

    it "updates record with values from params" do
      sign_in(@u)
      o = create(:order)
      new_date = '2020-01-01'
      put :update, id: o.id, order: { access_date_start: new_date }
      o.reload
      expect(o.access_date_start).to eq(Date.parse(new_date))
    end

    it "ignores params values not permitted by safe_attributes without raising an error" do
      sign_in(@u)
      o = create(:order)
      expect { put :update, id: o.id, order: { foo: 'boo' } }.not_to raise_error
    end

  end


  describe "DELETE #destroy" do
    it "returns http success" do
      sign_in(@u)
      o = create(:order)
      id = o.id
      delete :destroy, id: o.id
      expect(response).to have_http_status(:success)
      get :show, id: id
      expect(response).to have_http_status(400)
    end
  end


  describe "state changes" do
    it "changes state according to permitted transitions" do
      sign_in(@u)
      o = create(:order)
      event = o.available_events.first
      expect(o.current_state.to_s).to eq(o.initial_state.to_s)
      expect(put :update_state, id: o.id, event: event).to have_http_status(:success)
      expect(put :update_state, id: o.id, event: :foo).to have_http_status(403)
    end
  end


  describe "PUT deactivate_item and PUT activate_item" do
    it "deactivates and reactivates item" do
      sign_in(@u)
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

end
