class LocationsController < ApplicationController

  include SolrUtilities

  before_action :set_location, only: [ :show, :update, :destroy ]

  def index
    # @page = params[:page] || 1
    # @per_page = params[:per_page] || 20
    # @total = Location.count
    # @pages = (@total.to_f / @per_page.to_i).ceil
    # @sort = params[:sort] || :id
    # @locations = Location.paginate(page: @page, per_page: @per_page).order(@sort)
    # render json: @locations, meta: { pagination: pagination_params }, each_serializer: LocationSerializer

    @params = params
    @list = get_list_via_solr('location')
    @api_response = {
      locations: @list,
      meta: { pagination: pagination_params }
    }

    render json: @api_response
  end


  def show
    render json: @location
  end


  def create
    params[:location][:source_id] = Location.circa_location_source_id
    @location = Location.create!(location_params)
    render json: @location
  end


  def update
    @location.update!(location_params)
    render json: @location
  end


  def destroy
    @location.destroy!
    render json: {}
  end


  private


  def location_params
    params.require(:location).permit(:title, :source_id, :notes, :default)
  end


  def set_location
    @location = Location.find(params[:id])
  end



end
