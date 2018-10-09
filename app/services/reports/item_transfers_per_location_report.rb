class ItemTransfersPerLocationReport < GenerateReport


  private


  def generate
    @location_data = {}
    set_date_options()
    q = "to_state = 'in_transit_to_temporary_location'
        AND created_at #{ date_range_clause() }
        AND record_type = 'Item'"

    StateTransition.where(q).includes(record: [:permanent_location]).find_each do |t|
      item = t.record
      if (item)
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
    report_data = { location_values: @location_values, locations: @location_data }
    report_data.merge!(response_date_values)
    report_data
  end

end
