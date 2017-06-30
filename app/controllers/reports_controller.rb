class ReportsController < ApplicationController

  include DateUtilities

  def item_requests_per_resource
    @resource_data = {}

    @params = params

    set_date_options()

    total_item_requests = 0

    order_types = []

    Order.where("created_at #{ date_range_clause() }").find_each do |o|
      order_type = o.order_type[:value]
      order_types << order_type
      o.items.each do |i|
        @resource_data[i.resource_identifier] ||= { resource_title: i.resource_title, resource_uri: i.resource_uri, order_types: {} }
        @resource_data[i.resource_identifier][:order_types][order_type] ||= 0
        @resource_data[i.resource_identifier][:order_types][order_type] += 1
        total_item_requests += 1
      end
    end

    @resources = []
    @resource_data.each do |k,v|
      resource = v.clone
      resource[:resource_identifier] = k
      resource[:total_requests] = 0
      resource[:order_types].each { |type,value| resource[:total_requests] += value }
      sorted_types = resource[:order_types].sort_by { |type,value| value }
      sorted_types = sorted_types.reverse.map { |a| a[0] }
      resource[:sorted_order_types] = sorted_types
      @resources << resource
    end
    @resources.sort! { |a,b| a[:total_requests] <=> b[:total_requests] }
    @resources.reverse!
    @report_data = { total_resources: @resource_data.length, total_item_requests: total_item_requests, order_types: order_types.uniq, resources: @resources}

    @report_data.merge!(response_date_values)

    render json: @report_data
  end


  def access_sessions_per_patron_type

  end


  def item_requests_per_location
    @location_data = {}

    @params = params

    set_date_options()

    total_item_requests = 0

    Order.where("created_at #{ date_range_clause() }").find_each do |o|
      o.items.each do |i|
        if i.permanent_location
          facility = i.permanent_location.facility || 'other'
          build_dates_object_for_facility(facility)
          date_key = get_date_key(o.created_at)
          @location_data[facility][date_key] += 1
          total_item_requests += 1
        end
      end
    end

    set_location_values()

    @report_data = { location_values: @location_values,  total_locations: @location_data.length, total_item_requests: total_item_requests, locations: @location_data }
    @report_data.merge!(response_date_values)

    render json: @report_data
  end


  def item_usage_by_date
    # TK
  end


  def item_transfers_per_location
    @location_data = {}

    @params = params

    set_date_options()

    q = "to_state = 'in_transit_to_temporary_location' AND created_at #{ date_range_clause() }"

    StateTransition.where(q).find_each do |t|
      if t.record.class == Item
        item = t.record
        location = item.permanent_location
        if location && location.facility
          facility = location.facility
        else
          facility = 'unknown'
        end
        facility.strip!
        date_key = get_date_key(t.created_at)

        build_dates_object_for_facility(facility)
        @location_data[facility][date_key] += 1
      end
    end

    set_location_values()

    @report_data = { location_values: @location_values, locations: @location_data }
    @report_data.merge!(response_date_values)

    render json: @report_data
  end


  private


  def set_date_options
    @date_start = !@params[:date_start].blank? ? DateTime.parse(@params[:date_start]).to_date : Order.first_datetime.to_date
    @date_end = !@params[:date_end].blank? ? DateTime.parse(@params[:date_end]).to_date : Date.today
    @date_unit = @params[:date_unit] || 'month'
    @date_start_db = @date_start.to_datetime.to_s(:db)
    @date_end_db = @date_end.to_datetime.to_s(:db)

    case @date_unit
    when 'day'
      @date_values = date_range_to_single_dates(@date_start, @date_end)
    when 'week'
      @date_values = date_range_to_weeks(@date_start, @date_end).map { |d| d[0] }
    when 'month'
      @date_values = date_range_to_months(@date_start, @date_end)
    end
  end


  def get_date_key(date)
    case @date_unit
    when 'day'
      date_key = date.strftime('%Y-%m-%d')
    when 'week'
      date_key = date_to_week(date)[0]
    when 'month'
      date_key = date.strftime('%Y-%m')
    end
    date_key
  end


  def date_range_clause
    "BETWEEN '#{ @date_start_db }' AND '#{ @date_end_db }'"
  end


  def response_date_values
    { date_start: @date_start, date_end: @date_end, date_unit: @date_unit, date_values: @date_values }
  end


  def build_dates_object_for_facility(facility)
    if !@location_data[facility]
      @location_data[facility] = {}
      @date_values.each do |d|
        @location_data[facility][d] ||= 0
      end
    end
  end


  def set_location_values
    @location_values = @location_data.keys
    if @location_values.include?('unknown')
      @location_values.delete('unknown')
      @location_values.push('unknown')
    end
  end

end
