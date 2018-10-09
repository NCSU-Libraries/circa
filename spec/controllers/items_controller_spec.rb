require 'rails_helper'

RSpec.describe ItemsController, type: :controller do

  before(:each) do
    # DatabaseCleaner.clean_with(:deletion)
    # DatabaseCleaner.clean
    populate_roles
    r = UserRole.last
    @u = create(:user, user_role_id: r.id)
  end


  let(:user) { create(:user) }


  before(:each) do
    sign_in(user)
  end



  describe "GET #index" do
    it "returns http ok" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end


  describe "GET #show" do
    it "returns http ok" do
      i = create(:item)
      get :show, params: { id: i.id }
      expect(response).to have_http_status(:ok)
    end
  end


  describe "GET #create" do
    it "returns http ok" do
      get :create
      expect(response).to have_http_status(:ok)
    end
  end


  describe "PUT #update" do
    it "updates record and returns http ok" do
      l1 = create(:location)
      l2 = create(:location)
      i = create(:item, current_location_id: l1.id)
      expect(i.current_location_id).to eq(l1.id)
      put :update, params: { id: i.id, item: { current_location_id: l2.id } }
      expect(response).to have_http_status(:ok)
      i.reload
      expect(i.current_location_id).to eq(l2.id)
    end
  end


  describe "GET #destroy" do
    it "returns http ok" do
      i = create(:item)
      get :destroy, params: { id: i.id }
      expect(response).to have_http_status(:ok)
    end
  end


  describe "state changes" do
    it "changes state and stores applicable metadata" do
      o = create(:order_with_items)
      i = o.items.first
      o.trigger(:confirm, transition_metadata(user))
      event = i.available_events.first
      expect(put :update_state, params: { id: i.id, event: event, order_id: o.id }).to have_http_status(:ok)
      i.reload
      expect(i.last_transition.order_id).to eq(o.id)
    end
  end


  describe "POST #check_out" do

    it "checks out item and creates AccessSession record when proper params are passed" do
      o = create(:order_with_items)
      i = o.items.first
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      o.trigger(:confirm, transition_metadata(u))
      # move item through workflow
      i.trigger(:order, transition_metadata(u,o))
      i.trigger(:transfer, transition_metadata(u,o))
      i.trigger(:receive_at_temporary_location, transition_metadata(u,o))
      i.trigger(:prepare_at_temporary_location, transition_metadata(u,o))
      expect(i.current_state).to eq(:ready_at_temporary_location)
      post :check_out, params: { id: i.id, users: [ u.attributes ], order_id: o.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns 400 if item is already in use" do
      i = create(:item)
      o = create(:order)
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      a = create(:access_session, item_id: i.id, order_id: o.id, active: true)
      # move item through workflow
      i.trigger(:order, transition_metadata(u,o))
      i.trigger(:transfer, transition_metadata(u,o))
      i.trigger(:receive_at_temporary_location, transition_metadata(u,o))
      i.trigger(:prepare_at_temporary_location, transition_metadata(u,o))
      post :check_out, params: { id: i.id, users: [ u.attributes ], order_id: o.id }
      expect(response).to have_http_status('400')
    end

  end


  describe "GET #check_in" do
    it "checks in an in-use item" do
      o = create(:order_with_items)
      i = o.items.first
      r = UserRole.last
      u = create(:user, user_role_id: r.id)
      o.trigger(:confirm, transition_metadata(u))
      # move item through workflow
      i.trigger(:order, transition_metadata(u,o))
      i.trigger(:transfer, transition_metadata(u,o))
      i.trigger(:receive_at_temporary_location, transition_metadata(u,o))
      i.trigger(:prepare_at_temporary_location, transition_metadata(u,o))
      post :check_out, params: { id: i.id, users: [ u.attributes ], order_id: o.id }
      expect(i.in_use?).to be true
      get :check_in, params: { id: i.id }
      expect(i.in_use?).to be false
    end
  end


  describe "POST #create_from_archivesspace" do
    it "returns array of items as JSON" do
      api_values = archivesspace_api_values.first
      archivesspace_uri = api_values[:archival_object_uri]
      post :create_from_archivesspace, params: { archivesspace_uri: archivesspace_uri }
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['items']
      expect(i).not_to be_nil
    end

    it "creates items from ArchivesSpace digital objects and serialized digital object attributes" do
      api_values = archivesspace_digital_object_api_values
      archivesspace_uri = api_values[:archival_object_uri]
      post :create_from_archivesspace, params: { archivesspace_uri: archivesspace_uri, digital_object: true }
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['items']
      expect(i).not_to be_nil
      expect(i.first['digital_object']).to be true
    end
  end


  describe "POST #create_from_catalog" do
    it "returns item as JSON" do
      catalog_item = catalog_request_item
      catalog_record_id = catalog_item[:recordSpec]
      catalog_item_id = catalog_item[:barcode]
      post :create_from_catalog, params: { catalog_record_id: catalog_record_id, catalog_item_id: catalog_item_id }
      expect(response).to have_http_status('200')
      expect{ JSON.parse(response.body) }.not_to raise_error
      i = JSON.parse(response.body)['item']
      expect(i).not_to be_nil
    end
  end


  describe "POST #receive_at_temporary_location" do
    it "updates the items current location based on order location" do
      o = create(:order_with_items)
      l = create(:location)
      i = o.items.first
      o.trigger(:confirm, transition_metadata(user))
      # move item through workflow
      i.trigger(:order, transition_metadata(user,o))
      i.trigger(:transfer, transition_metadata(user,o))
      post :receive_at_temporary_location, params: { id: i.id, order_id: o.id }
      i.reload
      expect(i.current_location_id).to eq(o.location_id)
    end
  end


end
