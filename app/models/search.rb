class Search

  include GeneralUtilities
  include SolrConnect

  ######################################
  # CONFIG
  ######################################
  #
  # Query fields:
  #   Set Solr 'qf' parameter, which specifies fields to search and boost factor for each
  #   SEE: https://cwiki.apache.org/confluence/display/solr/The+DisMax+Query+Parser#TheDisMaxQueryParser-Theqf(QueryFields)Parameter
  #   Keys in @@query_fields hash are field names, values are associated boost factors

  @@query_fields = {
    'resource_title' => 1000,
    'resource_title_t' => 100,
    'notes' => nil,
    'resource_identifier' => 1000,
    'resource_identifier_t' => nil,
    'resource_ids_txt' => 1000,
    'location' => nil,
    'call_number' => 1000,
    'record_id' => 100,
    'email' => 1000,
    'email_t' => nil,
    'first_name' => 50,
    'first_name_t' => nil,
    'last_name' => 100,
    'last_name_t' => nil,
    'affiliation' => nil,
    'user_email_txt' => nil,
    'user_first_name_txt' => nil,
    'user_last_name_txt' => nil,
    'course_number' => 1000,
    'course_number_txt' => nil,
    'course_name' => 1000,
    'course_name_txt' => nil
    # 'assignee_email_txt' => nil,
    # 'assignee_first_name_txt' => nil,
    # 'assignee_last_name_txt' => nil
  }

  # Set defaults for options (described above):
  #
  # :per_page
  @@per_page_default = 20

  # :mm
  @@mm_default = '2<75%'

  # :ps
  @@ps_default = 3

  # 'facet.limit'
  @@facet_limit_default = -1

  # 'facet.mincount'
  @@facet_mincount_default = 1

  # 'group.limit'
  @@group_limit_default = 5
  ###

  ######################################
  # END CONFIG
  ######################################

  def initialize(options = {})
    @options = options.clone
    @q = options[:q]
    @filters = !options[:filters].blank? ? options[:filters] : {}
    @page = options[:page] || 1
    @per_page = options[:per_page] ? options[:per_page].to_i : @@per_page_default
    @lucene = options[:lucene] || nil
    @wt = options[:wt] || :ruby
    @start = options[:start] || ((@page.to_i - 1) * @per_page)
    @sort = options[:sort]
  end


  attr_accessor :q, :page, :per_page, :filters, :wt, :lucene


  def set_solr_params
    @solr_params = { :wt => self.wt || :ruby }
    @solr_params[:start] = @start
    @solr_params[:rows] = self.per_page
    @solr_params[:sort] = @sort ? @sort : nil

    if !self.lucene
      @solr_params[:defType] = 'edismax'
      @solr_params['q.alt'] = '*:*'

      # query string
      if !self.q.blank?
        @solr_params[:q] = self.q
      end

      ## result grouping
      if @options[:group] && @options['group.field']
        @solr_params['group'] = true
        @solr_params['group.field'] = @options['group.field']
        @solr_params['group.limit'] = @options['group.limit'] || @@group_limit_default
      end

      ## highlighting
      # @solr_params['hl'] = true
      # @solr_params['hl.fl'] = ''
      # @solr_params['hl.simple.pre'] = "<mark>"
      # @solr_params['hl.simple.post'] = "</mark>"

      # Set qf using query_fields above
      @solr_params[:qf] = ''
      @@query_fields.each do |k,v|
        @solr_params[:qf] += " #{k}"
        @solr_params[:qf] += v ? "^#{v}" : ''
      end
      @solr_params[:qf].strip!

      ## facets
      if @options[:facet] && @options['facet.field']
        @solr_params['facet'] = true
        @solr_params['facet.field'] = []
        @solr_params['facet.limit'] = @@facet_limit_default
        @solr_params['facet.mincount'] = @@facet_mincount_default
      end

      # boost query
      @solr_params[:bq] = @options[:bq] || []

      # minimum match
      @solr_params[:mm] = @options[:mm] || @@mm_default

      # phrase fields/slop
      @solr_params[:pf] = @@query_fields.keys
      @solr_params[:ps] = @@ps_default

    else
      @solr_params[:defType] = 'lucene'
      @solr_params[:q] = self.q
    end

    # process filters (selected facets or :fq passed in params)
    if @options[:fq]
      @solr_params['fq'] = @options[:fq]
    else
      @fq = []
      if !@filters.blank?
        @filters.each do |k,v|
          case v
          when String
            # don't quote value for range queries
            if v.match(/^\[/)
              @fq << "#{k}: #{v}"
            elsif !nil_or_empty?(v)
              @fq << "#{k}: \"#{v}\""
            end
          when Array
            if !nil_or_empty?(v)
              v.each { |f| @fq << "#{k}: \"#{f}\"" }
            end
          else
            @fq << "#{k}: #{v}"
          end
        end
      end
      @solr_params['fq'] = @fq
    end

    @solr_params
  end


  def execute
    Rails.logger.info "SOLR URL: #{@@solr_url}"
    Rails.logger.debug ENV.keys.inspect

    @solr = RSolr.connect :url => @@solr_url
    set_solr_params()

    @response = @solr.paginate self.page, self.per_page, "select", :params => @solr_params
  end


  # Load custom methods if they exist
  begin
    include SearchCustom
  rescue
  end

end
