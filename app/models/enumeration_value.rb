class EnumerationValue < ActiveRecord::Base

  belongs_to :enumeration

  before_destroy :deletable?

  def deletable?
    associated_records_count == 0 ? true : false
  end


  def associated_records_count
    ename = enumeration_name
    records = nil
    case ename
    when 'order_type'
      records = Order.where(order_type_id: id)
    when 'patron_type'
      records = User.where(patron_type_id: id)
    when 'location_source'
      records = Location.where(source_id: id)
    when 'user_role'
      records = User.where(user_role_id: id)
    end
    records ? records.length : 0
  end


  def enumeration_name
    e = Enumeration.find_by_id(enumeration_id)
    e ? e.name : nil
  end

end
