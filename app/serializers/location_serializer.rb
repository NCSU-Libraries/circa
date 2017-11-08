class LocationSerializer < ActiveModel::Serializer
  attributes :id, :title, :uri, :notes, :created_at, :updated_at, :source, :deletable

  def deletable
    object.deletable?
  end
end
