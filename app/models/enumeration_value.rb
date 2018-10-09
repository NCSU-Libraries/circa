class EnumerationValue < ApplicationRecord

  belongs_to :enumeration

  before_destroy :deletable?

  def self.values_by_enumeration_name(enum_name)
    enumeration = Enumeration.find_by(name: enum_name)
    if enumeration
      self.where(enumeration_id: enumeration.id)
    end
  end


  def deletable?
    associated_records_count == 0 ? true : false
  end


  def associated_records_count
    ename = enumeration_name
    records = nil
    case ename
    when 'researcher_type'
      records = User.where(researcher_type_id: id)
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


  # Load custom concern if present - methods in concern override those in model
  begin
    include EnumerationValueCustom
  rescue
  end

end
