class SerializeOrderHistory < SerializeRecord


  private


  def serialize
    @response = { order: {} }
    add_attributes
    if @options[:include_associations]
      add_associations
    end
    @response
  end


  # Adds both native attributes and values generated from instance methods
  def add_attributes
    atts = [
      :id, :access_date_start, :access_date_end, :order_type_id, :confirmed,
      :open, :created_at, :updated_at, :history
    ]
    atts.each do |a|
      case a
      when :created_at, :updated_at, :access_date_start, :access_date_end
        value = @record.send(a)
        value = format_datetime_value(value)
      else
        value = @record.send(a)
      end
      @response[:order][a] = value if value
    end
  end


  def add_associations
    skip_associations = @options[:skip_associations] || []
    # to-one associations
    to_one_associations = [ :order_type, :order_sub_type ]
    to_one_associations.each do |a|
      if !skip_associations.include?(a)
        association = @record.send(a)
        if association
          @response[:order][a] = serialize_attributes(association)
        end
      end
    end
  end

end
