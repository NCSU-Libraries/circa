class ResearchersByTypeReport < GenerateReport

  private

  def generate
    report_data = {}
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
      group by ev.value
      order by user_count desc"

    results = ActiveRecord::Base.connection.execute(sql)

    results.each do |r|
      report_data[r[0]] = r[1]
    end

    report_data
  end

end
