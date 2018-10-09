require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  before(:all) do
    populate_roles
    @order = create(:order)
    @item = create(:item)
    @item_order = create(:item_order, order_id: @order.id, item_id: @item.id)
    @digital_collections_order = create(:digital_collections_order, order_id: @order.id)
    @reproduction_format = create(:reproduction_format)
    @reproduction_spec = create(:reproduction_spec, item_order_id: @item_order.id)
    @order_fee1 = create(:order_fee, record_type: 'ItemOrder', record_id: @item_order.id)
    @order_fee2 = create(:order_fee, record_type: 'DigitalCollectionsOrder', record_id: @digital_collections_order.id)
    @item_order.reload
    @digital_collections_order.reload
    @order.reload
  end

  let(:user) { create(:user) }

  before(:each) do
    sign_in(user)
  end


  describe "POST #create" do

    let(:api_values) { archivesspace_api_values.first }
    let(:archivesspace_uri) { api_values[:archival_object_uri] }
    let(:location) { create(:location) }
    let(:order_type) { OrderType.create(name: 'test', label: 'test') }
    let(:order_sub_type) { OrderSubType.create(name: 'test', label: 'test', order_type_id: order_type.id) }
    let(:reproduction_fee_order_sub_type) { create(:order_sub_type, name: 'reproduction_fee') }

    let(:item_orders) do
      item_records = create_list(:item, 3)
      item_orders = []
      item_records.each do |i|
        item_order = { item_id: i.id, archivesspace_uri: [ archivesspace_uri ] }
        item_orders << item_order
      end
      item_orders
    end

    let(:reproduction_item_orders) do
      reproduction_item_orders = []
      item_orders.each do |io|
        item_order = io
        item_order[:reproduction_spec] = {
          pages: 3,
          reproduction_format_id: @reproduction_format.id
        }
        item_order[:order_fee] = {
          per_unit_fee: 1.23
        }
        reproduction_item_orders << item_order
      end
      reproduction_item_orders
    end


    let(:digital_collections_orders_data) do
      [
        { resource_identifier: "image1", requested_images: [ 'imagefile1-1', 'imagefile1-2' ],
          order_fee: { per_unit_fee: 1.23 }
        }
      ]
    end


    let(:order_post_data) do
      {
        users: [ user.attributes ],
        temporary_location: { id: location.id },
        primary_user_id: user.id,
        order_type_id: order_type.id,
        order_sub_type_id: order_sub_type.id
      }
    end


    let(:course_reserve_data) do
      {
        course_number: '1234',
        course_name: 'course reserve name'
      }
    end

    it "creates order, and adds items and users, and returns json response with http ok" do
      order_data = order_post_data
      order_data[:item_orders] = item_orders
      post :create, params: { order: order_data }
      expect(response).to have_http_status(:ok)
      expect { JSON.parse response.body }.not_to raise_error
      r = JSON.parse(response.body)
      expect(r['order']['item_orders'].empty?).not_to be true
      expect(assigns(:order).archivesspace_records.include?(archivesspace_uri)).to be true
      expect(r['order']['users'].empty?).not_to be true
      expect(r['order']['primary_user_id']).to eq(user.id)
    end

    it "crates order with reproduction items, fees and specs" do
      order_data = order_post_data
      order_data['order_sub_type_id'] = reproduction_fee_order_sub_type.id
      order_data[:item_orders] = reproduction_item_orders
      post :create, params: { order: order_data }
      r = JSON.parse(response.body)
      expect(r['order']['item_orders'][0]['reproduction_spec']['pages']).to eq(3)
      expect(r['order']['item_orders'][0]['order_fee']['per_unit_fee']).to eq(1.23)
    end

    it "creates reproduction order with digital images with fees" do
      order_data = order_post_data
      order_data[:digital_collections_orders] = digital_collections_orders_data
      post :create, params: { order: order_data }
      r = JSON.parse(response.body)
      expect(r['order']['digital_collections_orders'].empty?).not_to be true
      expect(r['order']['digital_collections_orders'].length).to eq(1)
      expect(r['order']['digital_collections_orders'][0]['order_fee']['per_unit_fee']).to eq(1.23)
    end


    it "creates course reserve order" do
      order_data = order_post_data
      order_data[:item_orders] = item_orders
      order_data[:course_reserve] = course_reserve_data
      post :create, params: { order: order_data }
      r = JSON.parse(response.body)
      expect(r['order']['course_reserve']['course_number']).to eq('1234')
      expect(r['order']['course_reserve']['course_name']).to eq('course reserve name')
    end


    it "creates cloned course reserve order" do
      order_data = order_post_data
      order_data[:item_orders] = item_orders
      course_reserve = course_reserve_data
      course_reserve[:id] = 999999
      course_reserve[:order_id] = 999999
      order_data[:course_reserve] = course_reserve
      post :create, params: { order: order_data }
      r = JSON.parse(response.body)
      expect(r['order']['course_reserve']['course_number']).to eq('1234')
      expect(r['order']['course_reserve']['course_name']).to eq('course reserve name')
    end

  end


end
