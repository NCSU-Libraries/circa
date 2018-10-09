require 'active_support/concern'

module SolrList
  extend ActiveSupport::Concern

  included do

    include GeneralUtilities

    private

    def get_list_via_solr(record_type)
      @q = @params[:q]

      ######################################################################
      # Process request params
      ######################################################################

      @page = @params[:page] || 1
      @per_page = @params[:per_page] || 20
      @params[:sort] ||= 'created_at asc'
      @sort = @params[:sort]

      if @params[:reset_filters]
        @params[:filters] = {}
      else
        @params[:filters] ||= {}
      end

      # @filters = @params[:filters] || {}
      # @filters[:record_type] = record_type

      @params[:filters][:record_type] = record_type

      # convert values of '0' to false
      convert_false = Proc.new do |hash|
        hash.each do |k,v|
          if v == '0'
            hash[k] = false
          end
        end
      end
      convert_false.call(@params)
      convert_false.call(@params[:filters])

      # Remove filters with nil/empty values
      @params[:filters].delete_if { |k,v| nil_or_empty?(v) }

      # @filters only include facet values included in the request. Additional filters will be added to the query.
      @filters = !@params[:filters].blank? ? @params[:filters].clone : {}

      s = Search.new(@params)
      @solr_response = s.execute

      @total = @solr_response['response']['numFound']
      @pages = (@total.to_f / @per_page.to_i).ceil

      @solr_response['response']['docs'].map { |d| JSON.parse(d['data']) }
    end
  end

end
