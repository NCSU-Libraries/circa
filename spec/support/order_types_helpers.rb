module OrderTypesHelpers

  include EnumerationUtilities

  def order_types
    order_types = []
    enumeration = Enumeration.find_by_name 'order_type'
    EnumerationValue.where(enumeration_id: enumeration.id).each { |ev| order_types << ev.attributes }
    order_types
  end


  def order_types_by_value_short
    types = {}
    order_types.each do |ot|
      types[ot[:value_short]] = ot
    end
  end

end
