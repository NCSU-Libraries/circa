module EnumerationUtilities


  def self.included receiver
    receiver.extend self
  end


  def get_enumeration_value(enumeration_value_id)
    e = EnumerationValue.find_by_id(enumeration_value_id)
    e ? e.value : nil
  end


  def get_enumeration_value_id(value_short, enumeration_name)
    sql = "SELECT ev.id FROM enumeration_values ev
      JOIN enumerations e on e.id = ev.enumeration_id
      WHERE e.name = '#{ enumeration_name }' AND ev.value_short = '#{ value_short }'
      LIMIT 1"
    EnumerationValue.find_by_sql(sql).map { |ev| ev.id }.first
  end


end
