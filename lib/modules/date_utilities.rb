module DateUtilities

  def date_range_to_weeks(start_date, end_date)
    weeks = []
    start_date_day = start_date.strftime('%u').to_i
    end_date_day = end_date.strftime('%u').to_i
    day_start_diff = start_date_day - 1
    if day_start_diff > 0
      start_date = start_date - day_start_diff
    end
    day_end_diff = 7 - end_date_day
    if day_end_diff > 0
      end_date = end_date + day_end_diff
    end
    week_start = start_date
    week_end = start_date + 6
    until week_end > end_date
      weeks << [week_start.strftime('%Y-%m-%d'), week_end.strftime('%Y-%m-%d')]
      week_start = week_end + 1
      week_end = week_start + 6
    end
    weeks
  end


  def date_range_to_months(start_date, end_date)
    months = []
    start_date_month = [ start_date.strftime('%Y').to_i, start_date.strftime('%m').to_i, start_date.strftime('%Y-%m') ]
    end_date_month = [ end_date.strftime('%Y').to_i, end_date.strftime('%m').to_i, end_date.strftime('%Y-%m') ]
    month = start_date_month
    until month[2] > end_date_month[2]
      months << month[2]
      if month[1] == 12
        year = month[0] + 1
        month = [ year, 1, "#{year}-01" ]
      else
        month = [ month[0], month[1] + 1, "#{month[0]}-#{'%02d' % (month[1] + 1)}" ]
      end
    end
    months
  end


  def date_range_to_single_dates(start_date, end_date)
    dates = []
    date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s)
    until date > end_date
      dates << date.strftime('%Y-%m-%d')
      date += 1
    end
    dates
  end


  # returns Mon-Sun week that includes date
  def date_to_week(date)
    date = Date.parse(date.to_s)
    date_day = date.strftime('%u').to_i
    day_diff = date_day - 1
    week_start = (day_diff > 0) ? date - day_diff : date
    week_end = week_start + 6
    [week_start.strftime('%Y-%m-%d'), week_end.strftime('%Y-%m-%d')]
  end

end
