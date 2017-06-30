require 'rails_helper'

RSpec.describe "routes", type: :routing do

  it "routes /requests to orders#index" do
    expect(get '/requests').to route_to('orders#index')
  end

end
