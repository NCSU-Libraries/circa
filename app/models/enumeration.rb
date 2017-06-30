class Enumeration < ActiveRecord::Base

  has_many :enumeration_values


  def self.merge_values(from_value_id, to_value_id, enumeration_name)
    enumeration = Enumeration.find_by_name(enumeration_name)
    from_value = EnumerationValue.find(from_value_id)
    to_value = EnumerationValue.find(to_value_id)
    if from_value && to_value && (to_value.enumeration_id == enumeration.id)
      case enumeration_name
      when 'order_type'
        records_to_update = Order.where(order_type_id: from_value_id)
        attribute_name = :order_type_id
      when 'patron_type'
        records_to_update = User.where(patron_type_id: from_value_id)
        attribute_name = :patron_type_id
      when 'location_source'
        records_to_update = Location.where(source_id: from_value_id)
        attribute_name = :source_id
      when 'user_role'
        records_to_update = User.where(user_role_id: from_value_id)
        attribute_name = :user_role_id
      end

      records_to_update.each do |o|
        o.update_attributes(attribute_name => to_value_id)
      end
    end
  end


  def self.values_by_enumeration_name(enumeration_name)
    enumeration = Enumeration.find_by_name(enumeration_name)
    enumeration.enumeration_values
  end

end
