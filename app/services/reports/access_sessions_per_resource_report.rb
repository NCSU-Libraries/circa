class AccessSessionsPerResourceReport < GenerateReport


  private


  def generate
    @resource_data = {}
    set_date_options()
    total_item_requests = 0

    AccessSession.where("start_datetime #{ date_range_clause() }").includes(:item).find_each do |as|
      i = as.item
      @resource_data[i.resource_identifier] ||= {}
      @resource_data[i.resource_identifier][:sessions] ||= 0
      @resource_data[i.resource_identifier][:item_ids] ||= []
      @resource_data[i.resource_identifier][:sessions] += 1
      @resource_data[i.resource_identifier][:item_ids] << i.id
      @resource_data[i.resource_identifier][:item_ids].uniq!
      @resource_data[i.resource_identifier][:items] = @resource_data[i.resource_identifier][:item_ids].length
    end

    @resource_data

  end


end
