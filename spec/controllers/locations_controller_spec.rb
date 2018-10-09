require 'rails_helper'

RSpec.describe LocationsController, type: :controller do

  let(:user) { User.first || create(:user) }

  before(:each) do
    sign_in(user)
  end


  describe "GET #index" do

    it "returns http ok" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "redirects to sign_in if user is not logged in" do
      sign_in(nil)
      expect(get :index).to redirect_to('/users/sign_in')
    end


    it "returns response in expected JSON format" do
      create_list(:order, 20)
      get :index, params: { per_page: 5 }
      expect { JSON.parse response.body }.not_to raise_error
      r = JSON.parse(response.body)
      expect(r['locations'].length).to eq(5)
      expect(r['meta']['pagination']).not_to be_nil
    end

  end

end
