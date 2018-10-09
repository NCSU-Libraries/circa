class SerializeEnumerationValue < SerializeRecord


  private


  def serialize
    attributes = serialize_attributes(@record)
    [ :enumeration_name, :associated_records_count ].each do |a|
      attributes[a] = @record.send(a)
    end
    { enumeration_value: attributes }
  end

end
