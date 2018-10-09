class ItemRequestsPerLocationReport < GenerateReport

  private

  def generate
    @location_data = {}
    set_date_options()
    total_item_requests = 0

    Order.where("created_at #{ date_range_clause() }").includes(items: [ :permanent_location ]).find_each do |o|
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
    report_data = { location_values: @location_values,  total_locations: @location_data.length, total_item_requests: total_item_requests, locations: @location_data }
    report_data.merge!(response_date_values)
    report_data
  end

end
