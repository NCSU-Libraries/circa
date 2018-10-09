class SerializeOrderSubType < SerializeRecord


  private


  def serialize
    attributes = serialize_attributes(@record)
    @response = { order_sub_type: attributes }
    add_associations
    @response
  end


  def add_associations
    [:order_type, :default_location].each do |a|
      associated_record = @record.send(a)
      if associated_record
        @response[:order_sub_type][a] = serialize_attributes(associated_record)
      end
    end
  end

end
