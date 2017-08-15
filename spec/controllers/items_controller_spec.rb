require 'rails_helper'

RSpec.describe ItemsController, type: :controller do

  before(:each) do
    # DatabaseCleaner.clean_with(:deletion)
    # DatabaseCleaner.clean
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
  end


  describe "GET #show" do
    it "returns http success" do
      sign_in(@u)
      i = create(:item)
      get :show, id: i.id
      expect(response).to have_http_status(:success)
    end
  end


  describe "GET #create" do
    it "returns http success" do
      sign_in(@u)
      get :create
      expect(response).to have_http_status(:success)
    end
  end


  describe "PUT #update" do
    it "updates record and returns http success" do
      sign_in(@u)
      l1 = create(:location)
      l2 = create(:location)
      i = create(:item, current_location_id: l1.id)
      expect(i.current_location_id).to eq(l1.id)
      put :update, id: i.id, item: { current_location_id: l2.id }
      expect(response).to have_http_status(:success)
      i.reload
      expect(i.current_location_id).to eq(l2.id)
    end
  end


  describe "GET #destroy" do
    it "returns http success" do
      sign_in(@u)
      i = create(:item)
      get :destroy, id: i.id
      expect(response).to have_http_status(:success)
    end
  end


  describe "state changes" do
    it "changes state and stores applicable metadata" do
      sign_in(@u)
      o = create(:order_with_items)
      i = o.items.first
      o.trigger(:confirm)
      event = i.available_events.first
      expect(put :update_state, id: i.id, event: event, order_id: o.id).to have_http_status(:success)
      i.reload
      expect(i.last_transition.order_id).to eq(o.id)
    end
  end


  describe "POST #check_out" do

    it "checks out item and creates AccessSession record when proper params are passed" do
      sign_in(@u)
      o = create(:order_with_items)
      i = o.items.first
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      o.trigger(:confirm)
      # move item through workflow
      i.trigger(:order)
      i.trigger(:transfer)
      i.trigger(:receive_at_temporary_location)
      i.trigger(:prepare_at_temporary_location)
      expect(i.current_state).to eq(:ready_at_temporary_location)
      post :check_out, id: i.id, users: [ u.attributes ], order_id: o.id
      expect(response).to have_http_status(:success)
    end

    it "returns 400 if item is already in use" do
      sign_in(@u)
      i = create(:item)
      o = create(:order)
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      a = create(:access_session, item_id: i.id, order_id: o.id, active: true)
      # move item through workflow
      i.trigger(:order)
      i.trigger(:transfer)
      i.trigger(:receive_at_temporary_location)
      i.trigger(:prepare_at_temporary_location)
      post :check_out, id: i.id, users: [ u.attributes ], order_id: o.id
      expect(response).to have_http_status('400')
    end

  end


  describe "GET #check_in" do
    it "checks in an in-use item" do
      sign_in(@u)
      o = create(:order_with_items)
      i = o.items.first
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      o.trigger(:confirm)
      # move item through workflow
      i.trigger(:order)
      i.trigger(:transfer)
      i.trigger(:receive_at_temporary_location)
      i.trigger(:prepare_at_temporary_location)
      post :check_out, id: i.id, users: [ u.attributes ], order_id: o.id
      expect(i.in_use?).to be true
      get :check_in, id: i.id
      expect(i.in_use?).to be false
    end
  end


  describe "POST #create_from_archivesspace" do
    it "returns array of items as JSON" do
      sign_in(@u)
      api_values = archivesspace_api_values.first
      archivesspace_uri = api_values[:archival_object_uri]
      post :create_from_archivesspace, archivesspace_uri: archivesspace_uri
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['items']
      expect(i).not_to be_nil
    end

    it "creates items from ArchivesSpace digital objects and serialized digital object attributes" do
      sign_in(@u)
      api_values = archivesspace_digital_object_api_values
      archivesspace_uri = api_values[:archival_object_uri]
      post :create_from_archivesspace, archivesspace_uri: archivesspace_uri, digital_object: true
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['items']
      expect(i).not_to be_nil
      expect(i.first['digital_object']).to be true
    end
  end


  describe "POST #create_from_catalog" do
    it "returns item as JSON" do
      sign_in(@u)
      catalog_item = catalog_request_item
      catalog_record_id = catalog_item[:recordSpec]
      catalog_item_id = catalog_item[:barcode]
      post :create_from_catalog, catalog_record_id: catalog_record_id, catalog_item_id: catalog_item_id
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['item']
      expect(i).not_to be_nil
    end
  end


  describe "POST #receive_at_temporary_location" do
    it "updates the items current location based on order location" do
      sign_in(@u)
      o = create(:order_with_items)
      l = create(:location)
      i = o.items.first
      o.trigger(:confirm)
      # move item through workflow
      i.trigger(:order)
      i.trigger(:transfer)
      post :receive_at_temporary_location, id: i.id, order_id: o.id
      i.reload
      expect(i.current_location_id).to eq(o.location_id)
    end
  end


end
