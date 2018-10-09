require 'rails_helper'

RSpec.describe UtilityController, type: :controller do

  describe "GET #catalog_record" do

    it "returns JSON" do
      sign_in(create(:user))
      get :catalog_record, params: { catalog_record_id: 'NCSU604802' }
      expect{ JSON.parse(response.body)}.not_to raise_error
    end

    it "contains catalog record as value of record key" do
      sign_in(create(:user))
      get :catalog_record, params: { catalog_record_id: 'NCSU604802' }
      data = JSON.parse(response.body)
      expect(data.keys.first).to eq('data')
    end

    it "contains correct catalog record" do
      sign_in(create(:user))
      get :catalog_record, params: { catalog_record_id: 'NCSU604802' }
      data = JSON.parse(response.body)
      expect(data['data']['record']['recordSpec']).to eq('NCSU604802')
    end

  end

end
