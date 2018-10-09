require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  before(:all) do
    populate_roles
    r = UserRole.last
    @u = create(:user, user_role_id: r.id)
  end


  describe "GET #index" do
    it "returns http ok" do
      sign_in(@u)
      get :index
      expect(response).to have_http_status(:ok)
    end
  end


  describe "GET #show" do

    it "returns http ok when user is found" do
      sign_in(@u)
      get :show, params: { id: @u.id }
      expect(response).to have_http_status(:ok)
      get :show, params: { email: @u.email }
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 if user is not found" do
      sign_in(@u)
      get :show, params: { id: 0 }
      expect(response).to have_http_status(404)
      get :show, params: { email: 'foo' }
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
        user_type: 'researcher',
        user: {
          email: 'you@them.com', first_name: 'You', last_name: 'OK', agreement_confirmed_at: Time.now
        }
      }
      post :create, params: params
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
        user_type: 'researcher',
        user: {
          email: 'you1@them.com', first_name: 'You', last_name: 'OK', agreement_confirmed_at: Time.now,
          password: 'password123', password_confirmation: 'password123'
        }
      }
      post :create, params: params
      expect(response).to have_http_status(200)
      r = JSON.parse(response.body)
      user = User.find(r['user']['id'])
      expect(user.encrypted_password).not_to be_nil
    end
  end


  describe "PUT #update" do
    it "returns http ok" do
      @u = create(:admin_user)
      sign_in(@u)
      u = create(:user)
      put :update, params: { id: u.id, user: u.attributes }
      expect(response).to have_http_status(:ok)
    end
  end


  describe "DELETE" do
    it "returns http ok" do
      @u = create(:admin_user)
      sign_in(@u)
      u = create(:user)
      delete :destroy, params: { id: u.id }
      expect(response).to have_http_status(:ok)
    end
  end

end
