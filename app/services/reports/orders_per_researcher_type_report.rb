class OrdersPerResearcherTypeReport < GenerateReport

  private

  def generate
    report_data = {}
    set_date_options

    get_orders_for_researcher_type = lambda do |type_id|
      sql = "select ot.name, count(distinct o.id) as order_count
        from orders o
        join order_users ou on ou.order_id = o.id
        join users u on u.id = ou.user_id
        join order_sub_types ost on o.order_sub_type_id = ost.id
        join order_types ot on ot.id = ost.order_type_id
        where u.researcher_type_id = #{ type_id }
        and o.created_at #{ date_range_clause }
        group by ot.name"
      ActiveRecord::Base.connection.execute(sql)
    end

    EnumerationValue.values_by_enumeration_name('researcher_type').each do |ev|
      type_data = {}
      results = get_orders_for_researcher_type.(ev.id)
      type_data = {}
      results.each do |r|
        type_data[r[0]] = r[1]
      end
      report_data[ev.value] = type_data
    end

    report_data
  end


end
