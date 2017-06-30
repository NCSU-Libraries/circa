class EnumerationValueSerializer < ActiveModel::Serializer
  attributes :id, :enumeration_id, :enumeration_name, :value, :value_short, :associated_records_count, :created_at, :updated_at
end
