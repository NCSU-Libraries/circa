require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:user_role) { UserRole.last }
  let(:user) { create(:user, user_role_id: user_role.id) }

  before(:all) do
    populate_roles

    @order = create(:order)
    @item = create(:item)
    @item_order = create(:item_order, order_id: @order.id, item_id: @item.id)
    @digital_image_order = create(:digital_image_order, order_id: @order.id)
    @reproduction_spec = create(:reproduction_spec, item_order_id: @item_order.id)
    @order_fee1 = create(:order_fee, record_type: 'ItemOrder', record_id: @item_order.id)
    @order_fee2 = create(:order_fee, record_type: 'DigitalImageOrder', record_id: @digital_image_order.id)
    @item_order.reload
    @digital_image_order.reload

    puts @digital_image_order.inspect
    puts @item_order.inspect

    @order.reload
  end

  before(:each) do
    sign_in(user)
    get :show, id: @order.id
    @r = JSON.parse(response.body)
  end


  it "includes item_orders in response" do
    expect(@r['order']['item_orders'].length).to eq(1)
    expect(@r['order']['item_orders'][0]['item_id']).to eq(@item.id)
  end


  it "includes digital_image_orders in response" do
    expect(@r['order']['digital_image_orders'].length).to eq(1)
    expect(@r['order']['digital_image_orders'][0]['image_id']).to eq(@digital_image_order.image_id)
  end


  it "includes reproduction_spec in response" do
    expect(@r['order']['item_orders'][0]['reproduction_spec']['id']).to eq(@reproduction_spec.id)
  end


  it "includes order_fees in response" do
    expect(@r['order']['item_orders'][0]['order_fee']['id']).to eq(@order_fee1.id)
    expect(@r['order']['digital_image_orders'][0]['order_fee']['id']).to eq(@order_fee2.id)
  end


end
