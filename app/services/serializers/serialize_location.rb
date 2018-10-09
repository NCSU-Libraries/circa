# class LocationSerializer < ActiveModel::Serializer
#   attributes :id, :title, :uri, :notes, :created_at, :updated_at, :source, :deletable

#   def deletable
#     object.deletable?
#   end
# end


class SerializeLocation < SerializeRecord


  private


  def serialize
    @response = { location: {} }
    add_attributes
    # add_associations
    @response
  end


  def add_attributes
    atts = [
      :id, :title, :uri, :created_at, :updated_at, :source, :deletable, :notes
    ]
    atts.each do |a|
      case a
      when :created_at, :updated_at
        @response[:location][a] = @record.send(a).strftime('%FT%T%:z')
      when :deletable
        @response[:location][:deletable] = @record.deletable?
      else
        @response[:location][a] = @record.send(a)
      end
    end
  end


  # :notes
  # def add_associations
  #   if @record.notes
  #     @response[:location][:notes] = []
  #     @record.notes.each do |note|
  #       @response[:location][:notes] << note.attributes
  #     end
  #   end
  # end


end
