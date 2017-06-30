class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :current_sign_in_at, :last_sign_in_at, :created_at, :updated_at,
  :unity_id, :position, :affiliation, :first_name, :last_name, :display_name, :address1, :address2,
  :city, :state, :zip, :country, :phone, :agreement_confirmed, :patron_type, :patron_type_id,
  :user_role_id, :role, :is_admin, :assignable_roles, :current_password

  has_many :orders, serializer: UserOrdersSerializer
  has_many :notes
  belongs_to :user_role

  def agreement_confirmed
    object.agreement_confirmed_at ? true : false
  end

  def assignable_roles
    object.assignable_roles.map { |a| { id: a.id, name: a.name, level: a.level, users_count: a.users.length } }
  end

end
