class ItemRequestsPerResourceReport < GenerateReport

  private

  def generate
    @resource_data = {}
    set_date_options()
    total_item_requests = 0
    order_types = []

    Order.where("created_at #{ date_range_clause() }").includes(:order_type, :items).find_each do |o|
      order_type = o.order_type.name
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
    report_data = { total_records: @resource_data.length, total_item_requests: total_item_requests, order_types: order_types.uniq, resources: @resources}
    report_data.merge!(response_date_values)

    report_data
  end

end
