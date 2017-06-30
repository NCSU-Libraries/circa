require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  before(:all) do
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

    it "returns http success when user is found" do
      sign_in(@u)
      get :show, id: @u.id
      expect(response).to have_http_status(:success)
      get :show, email: @u.email
      expect(response).to have_http_status(:success)
    end

    it "returns 404 if user is not found" do
      sign_in(@u)
      get :show, id: 0
      expect(response).to have_http_status(404)
      get :show, email: 'foo'
      expect(response).to have_http_status(404)
    end

    it "returns 400 if no id or email is provided" do
      sign_in(@u)
      get :show
      expect(response).to have_http_status(400)
    end

  end


  describe "POST #create" do
    it "creates a user from passed parameters" do
      @u = create(:admin_user)
      sign_in(@u)
      params = {
        user_type: 'patron',
        user: {
          email: 'you@them.com', first_name: 'You', last_name: 'OK', agreement_confirmed_at: Time.now
        }
      }
      post :create, params
      expect(response).to have_http_status(200)
      expect { JSON.parse response.body }.not_to raise_error
      r = JSON.parse(response.body)
      expect(r['user']['email']).to eq( params[:user][:email] )
    end
  end


  describe "POST #create" do
    it "create sets user password" do
      @u = create(:admin_user)
      sign_in(@u)
      params = {
        user_type: 'patron',
        user: {
          email: 'you1@them.com', first_name: 'You', last_name: 'OK', agreement_confirmed_at: Time.now,
          password: 'password123', password_confirmation: 'password123'
        }
      }
      post :create, params
      expect(response).to have_http_status(200)
      r = JSON.parse(response.body)
      user = User.find(r['user']['id'])
      expect(user.encrypted_password).not_to be_nil
    end
  end


  describe "PUT #update" do
    it "returns http success" do
      @u = create(:admin_user)
      sign_in(@u)
      u = create(:user)
      put :update, id: u.id, user: u.attributes
      expect(response).to have_http_status(:success)
    end
  end


  describe "DELETE" do
    it "returns http success" do
      @u = create(:admin_user)
      sign_in(@u)
      u = create(:user)
      delete :destroy, id: u.id
      expect(response).to have_http_status(:success)
    end
  end

end
