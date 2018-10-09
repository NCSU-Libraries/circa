# superclass for all "serialize_" service objects
class SerializeRecord

  def self.call(record, options = { include_associations: true })
    object = new(record, options)
    object.call
  end

  def initialize(record, options = { include_associations: true })
    @record = record
    @options = options
  end

  def call
    serialize
  end


  private


  def serialize
    @key = @record.class.to_s.underscore.to_sym
    @response = { @key => serialize_attributes(@record) }

    if @record.respond_to?(:notes) && @record.notes
      @response[@key][:notes] = serialize_notes
    end

    @response
  end


  def serialize_attributes(record)
    serialized = {}
    atts = record.class.column_names.map { |c| c.to_sym }
    atts.each do |a|
      case a
      when :created_at, :updated_at
        value = record.send(a)
        serialized[a] = format_datetime_value(value)
      else
        serialized[a] = record.send(a)
      end
    end
    serialized
  end


  def serialize_notes
    if @record.respond_to?(:notes) && @record.notes
      @record.notes.map { |n| serialize_attributes(n) }
    end
  end


  def format_datetime_value(value)
    value ? value.strftime('%FT%T%:z') : nil
  end

end
