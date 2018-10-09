require 'rails_helper'

RSpec.describe do

  let(:item) { create(:item) }

  it "does not raise exception" do
    expect { SerializeItem.call(item) }.not_to raise_error
  end

  let(:response) { SerializeItem.call(item) }

  it "returns a hash of record attributes" do
    expect(response).to be_a(Hash)
  end

  it "serializes attributes correctly" do
    expect(response[:item][:id]).to eq(item.id)
    expect(response[:item][:uri]).to eq(item.uri)
  end

  it "formats dates as string" do
    expect(response[:item][:created_at]).to be_a(String)
  end

  it "serializes locations" do
    expect(response[:item][:permanent_location][:id]).to eq(item.permanent_location.id)
    expect(response[:item][:current_location][:id]).to eq(item.current_location.id)
    expect(response[:item][:permanent_location][:uri]).to eq(item.permanent_location.uri)
    expect(response[:item][:current_location][:uri]).to eq(item.current_location.uri)
  end

end
