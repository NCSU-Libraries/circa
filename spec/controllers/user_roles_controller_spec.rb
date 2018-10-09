require 'rails_helper'

RSpec.describe UserRolesController, type: :controller do

  before(:all) do
    @u = create(:admin_user)
  end


  describe "GET #index" do
    it "returns http ok" do
      sign_in(@u)
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      sign_in(@u)
      get :index
      expect { JSON.parse(response.body) }.not_to raise_error
    end

    it "returns array of values from given enumeration name" do
      sign_in(@u)
      create(:user_role)
      get :index
      data = JSON.parse(response.body)
      expect(data).to be_a(Hash)
    end
  end


  describe "POST #create" do
    it "returns http ok" do
      sign_in(@u)
      post :create, params: { user_role: { name: 'test_for_spec' }, format: 'json' }
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      sign_in(@u)
      post :create, params: { user_role: { name: 'test_for_spec' }, format: 'json' }
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end


  describe "PUT #update" do
    it "returns http ok" do
      sign_in(@u)
      ur = create(:user_role)
      put :update, params: { id: ur.id, user_role: { user_role: ur.id, name: "#{ur.name}_updated" }, format: 'json' }
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      sign_in(@u)
      ur = create(:user_role)
      put :update, params: { id: ur.id, user_role: { user_role: ur.id, name: "#{ur.name}_updated" }, format: 'json' }
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end


  describe "DELETE" do
    it "returns http ok" do
      sign_in(@u)
      ur = create(:user_role)
      delete :destroy, params: { id: ur.id }
      expect(response).to have_http_status(:ok)
    end
  end


end
