class SearchController < ApplicationController

  # This controller is no longer used but I'm keeping it here just in case
  # All searches are model-specific and are integrated into the index actions for the respective controllers

  def index
    @q = params[:q]

    ######################################################################
    # Process request params
    ######################################################################

    @page = params[:page] || 1
    @per_page = params[:per_page] || 20
    @total = Order.count
    @pages = (@total.to_f / @per_page.to_i).ceil
    @sort = params[:sort] || :id

    if params[:reset_filters]
      params[:filters] = {}
    else
      params[:filters] ||= {}
    end

    @filters = params[:filters] || {}

    # remove filters with no value
    params[:filters].delete_if { |k,v| v.blank? }

    # convert values of '0' to false
    params.each do |k,v|
      if v == '0'
        params[k] = false
      end
    end

    # @filters only include facet values included in the request. Additional filters will be added to the query.
    @filters = !params[:filters].blank? ? params[:filters].clone : {}

    s = Search.new(params)
    @solr_response = s.execute

    # @api_response = {
    #   orders: @solr_response['response']['docs'].map { |d| JSON.parse(d['data']) },
    #   meta: { pagination: pagination_params }
    # }

    render json: @solr_response

  end


  # Load custom concern if present
  begin
    include SearchControllerCustom
  rescue
  end


end
