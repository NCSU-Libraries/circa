class UserRoleSerializer < ActiveModel::Serializer

  attributes :id, :name, :level, :users_count

  def users_count
    object.users.length
  end

end
