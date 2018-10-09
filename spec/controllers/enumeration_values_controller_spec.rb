require 'rails_helper'

RSpec.describe EnumerationValuesController, type: :controller do

  before(:all) do
    populate_roles
    @u = create(:user)
    @e = Enumeration.create(name: 'order_type')
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
      EnumerationValue.create(value: 'type1', enumeration_id: @e.id)
      get :index, params: { enumeration_name: 'order_type' }
      data = JSON.parse(response.body)
      expect(data).to be_a(Hash)
    end
  end


  describe "POST #create" do
    it "returns http ok" do
      sign_in(@u)
      post :create, params: { enumeration_value: { enumeration_id: @e.id, value: 'type1' }, format: 'json' }
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      sign_in(@u)
      post :create, params: { enumeration_value: { enumeration_id: @e.id, value: 'type1' }, format: 'json' }
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end


  describe "PUT #update" do
    it "returns http ok" do
      sign_in(@u)
      ev = EnumerationValue.create(value: 'type1', enumeration_id: @e.id)
      put :update, params: { id: ev.id, enumeration_value: { enumeration_id: @e.id, value: 'type2' }, format: 'json' }
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      sign_in(@u)
      ev = EnumerationValue.create(value: 'type1', enumeration_id: @e.id)
      put :update, params: { id: ev.id, enumeration_value: { enumeration_id: @e.id, value: 'type2' }, format: 'json' }
      expect { JSON.parse(response.body) }.not_to raise_error
    end
  end


  describe "DELETE" do
    it "returns http ok" do
      @u = create(:admin_user)
      sign_in(@u)
      ev = EnumerationValue.create(value: 'type1', enumeration_id: @e.id)
      delete :destroy, params: { id: ev.id }
      expect(response).to have_http_status(:ok)
    end
  end

end
