class ResearchersByTypeReport < GenerateReport

  private

  def generate
    report_data = {}
    set_date_options

    # limit to research and reproduction orders
    order_type_ids = OrderType.where(
        "name in ('research', 'reproduction')").map { |o| o.id }

    sql = "select ev.value, count(distinct u.id) as user_count from enumeration_values ev
      join enumerations e on e.id = ev.enumeration_id
      join users u on u.researcher_type_id = ev.id
      join order_users ou on ou.user_id = u.id
      join orders o on o.id = ou.order_id
      join order_sub_types ost on o.order_sub_type_id = ost.id
      where ost.order_type_id in (#{ order_type_ids.join(',') })
      and e.name = 'researcher_type'
      and o.created_at #{ date_range_clause }
      group by ev.value
      order by user_count desc"

    results = ActiveRecord::Base.connection.execute(sql)


    EnumerationValue.values_by_enumeration_name('researcher_type').each do |ev|
      report_data[ev.value] = 0
    end

    results.each do |r|
      report_data[r[0]] = r[1]
    end

    report_data
  end

end
