require 'rails_helper'

RSpec.describe do

  let(:location) { create(:location) }

  it "does not raise exception" do
    expect { SerializeRecord.call(location) }.not_to raise_error
  end

  let(:response) { SerializeRecord.call(location) }

  it "returns a hash of record attributes" do
    expect(response).to be_a(Hash)
  end

  it "serializes attributes correctly" do
    expect(response[:location][:title]).to eq(location.title)
    expect(response[:location][:uri]).to eq(location.uri)
  end

  it "formats dates as string" do
    expect(response[:location][:created_at]).to be_a(String)
  end

end
