class UniqueVisitsReport < GenerateReport


  private


  def generate
    set_date_options()

    where = "start_datetime #{ date_range_clause() }"

    report_data = {}
    report_data_raw = {}

    AccessSession.where(where).order('start_datetime ASC').includes(:users).find_each do |r|
      date_key = get_date_key(r.start_datetime)
      report_data_raw[date_key] ||= []
      r.users.each do |u|
        report_data_raw[date_key] << u.email
      end
    end

    report_data_raw.each do |k,v|
      report_data[k] = v.uniq.length
    end

    report_data_sorted = {}
    report_data.keys.sort.reverse.each do |k|
      report_data_sorted[k] = report_data[k]
    end

    report_data_sorted
  end

end
