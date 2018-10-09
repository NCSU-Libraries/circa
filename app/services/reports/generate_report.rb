# superclass for all "generate_..._report" service objects

class GenerateReport


  include DateUtilities


  def self.call(params = {})
    object = new(params)
    object.call
  end

  def initialize(params = {})
    @params = params
  end

  def call
    generate
  end


  private


  # define generate in each report service
  # def generate
  # end


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
    { date_start: @date_start, date_end: @date_end, date_unit: @date_unit, date_values: @date_values.reverse }
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
