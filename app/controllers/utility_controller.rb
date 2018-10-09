class UtilityController < ApplicationController


  include AspaceUtilities


  def uuid
    render text: SecureRandom.uuid
  end


  def get_archivesspace_record
    if params[:uri]
      @uri = params[:uri]
      @params = params[:params] || {}
      @headers = params[:headers] || {}
      @params[:resolve] = ['resource']
      response = aspace_api_get(@uri, @params, @headers)
      if response
        render text: response
      end
    end
  end


  def archivesspace_data
    case params[:request]
    when 'resources_per_accession'
      return_data = params[:identifier] ?
          archivesspace_resources_per_accession(params[:identifier]) : {}
    end
    render json: return_data
  end


  def user_data
    if !:user_signed_in?
      redirect_to '/users/sign_in'
    else
      @user = current_user
      # @user = current_user.clone
      render json:  SerializeUser.call(@user)
    end
  end


  def archivesspace_resolver
    protocol = ENV['archivesspace_https'] ? 'https://' : 'http://'
    host = ENV['archivesspace_frontend_host'] ? ENV['archivesspace_frontend_host'] :
        ENV['archivesspace_host']
    port = ENV['archivesspace_frontend_port'] ? ENV['archivesspace_frontend_port'] :
        nil
    redirect_url = "#{protocol}#{host}"
    redirect_url += port ? ":#{port}" : ''
    redirect_url += '/resolve/readonly?uri=/'
    redirect_url += params[:archivesspace_uri]
    redirect_to redirect_url
  end


  def user_typeahead
    params[:q] ||= ''
    solr_params = { lucene: true, filters: { 'record_type' => 'user'} }
    if params[:q].length > 0
      q = URI.unescape(params[:q])
      if q =~ /\s/
        name_parts = q.split(' ')
        first_name = name_parts.delete_at(0)
        first_name_q = "(first_name:#{first_name}* OR first_name_t:#{first_name}*)"
        last_name_q = "("
        name_parts.each do |lname|
          last_name_q += "last_name:#{lname}* OR last_name_t:#{lname}*"
          last_name_q += lname != name_parts.last ? ' OR ' : ''
        end
        last_name_q += ")"
        query = "#{first_name_q} AND #{last_name_q}"
      else
        query = "(first_name:#{q}* OR last_name:#{q}* OR first_name_t:#{q}* OR last_name_t:#{q}* OR email:#{q}* OR email_t:#{q}* OR display_name_t:#{q}*)"
      end

      if params[:internal]
        query += " AND user_role_id:( #{ UserRole.internal_role_ids.join(' OR ') })"
      end

      solr_params[:q] = query

      puts '***'
      puts solr_params.inspect
      puts '***'

      s = Search.new(solr_params)
      solr_response = s.execute
      @api_response = {
        users: solr_response['response']['docs'].map { |d| JSON.parse(d['data']) },
      }
    else
      @api_response = { users: [] }
    end
    render json: @api_response
  end


  def enumeration_values
    if params[:enumeration_name]
      e = Enumeration.find_by_name(params[:enumeration_name])
    elsif params[:enumeration_id]
      e = Enumeration.find_by_id(params[:enumeration_id])
    else
      e = nil
    end

    all_enumeration_values = lambda do
      all_values = {}
      Enumeration.find_each do |enumeration|
        values = EnumerationValue.where(enumeration_id: enumeration.id)
        all_values[enumeration.name] = values.map { |ev| {
          id: ev.id, value: ev.value, value_short: ev.value_short
        } }
      end
      return all_values
    end

    @values = e ? EnumerationValue.where(emueration_id: e.id).map { |ev| ev.attributes } : all_enumeration_values.call
    render json: @values
  end


  # Provides the following values to the front end:
  #  * order_types
  #  * order_sub_types
  #  * researcher_type (from enumeration_values)
  def controlled_values
    @values = { order_type: [], order_sub_type: [], researcher_type: [],
        reproduction_format: [] }

    #order_type
    OrderType.find_each do |ot|
      @values[:order_type] << { id: ot.id, name: ot.name, label: ot.label,
      default_order_sub_type: ot.default_order_sub_type,
      default_order_sub_type_id: ot.default_order_sub_type_id }
    end

    #order_sub_type
    OrderSubType.find_each do |ost|
      @values[:order_sub_type] << { id: ost.id, name: ost.name,
          label: ost.label, order_type_id: ost.order_type_id,
          default_location_id: ost.default_location_id,
          default_location: ost.default_location }
    end

    #researcher_type
    researcher_type_enumeration = Enumeration.where(name: 'researcher_type').first
    EnumerationValue.where(enumeration_id: researcher_type_enumeration.id).find_each do |ev|
      @values[:researcher_type] << { id: ev.id, value: ev.value, value_short: ev.value_short }
    end

    # reproduction_format
    ReproductionFormat.find_each do |rf|
      @values[:reproduction_format] << {
        id: rf.id,
        name: rf.name,
        description: rf.description,
        default_unit_fee: rf.default_unit_fee,
        default_unit_fee_internal: rf.default_unit_fee_internal,
        default_unit_fee_external: rf.default_unit_fee_external
      }
    end

    render json: { controlled_values: @values }
  end


  def circa_locations
    @locations = Location.where(source_id: Location.circa_location_source_id)
    render json: { locations: @locations }
  end


  def states_events
    api_response = {
      order_states_events: Order.states_events,
      item_states_events: Item.states_events
    }
    render json: api_response
  end


  def options
    option_keys = [
      'send_order_notifications', 'use_devise_passwords'
    ]
    option_values = {}
    option_keys.each { |k| option_values[k] = ENV[k] }
    render json: option_values
  end


  # Load custom concern if present
  begin
    include UtilityControllerCustom
  rescue
  end

end
