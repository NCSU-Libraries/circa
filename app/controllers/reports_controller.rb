class ReportsController < ApplicationController

  include DateUtilities

  def item_requests_per_resource
    report_data = ItemRequestsPerResourceReport.call(params)
    render json: report_data
  end


  def orders_per_researcher_type
    report_data = OrdersPerResearcherTypeReport.call(params)
    render json: report_data
  end


  def researchers_per_type
    report_data = ResearchersByTypeReport.call(params)
    render json: report_data
  end


  def item_requests_per_location
    report_data = ItemRequestsPerLocationReport.call(params)
    render json: report_data
  end


  def item_transfers_per_location
    report_data = ItemTransfersPerLocationReport.call(params)
    render json: report_data
  end


  def unique_visits
    report_data = UniqueVisitsReport.call(params)
    render json: report_data
  end


  # Load custom concern if present
  begin
    include ReportsControllerCustom
  rescue
  end

end
