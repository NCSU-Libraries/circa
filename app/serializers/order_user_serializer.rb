class OrderUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :current_sign_in_at, :last_sign_in_at, :created_at, :updated_at,
  :unity_id, :position, :affiliation, :first_name, :last_name, :display_name, :address1, :address2,
  :city, :state, :zip, :country, :phone, :open_orders, :agreement_confirmed, :patron_type,
  :has_active_access_session,
  :role, :roles, :is_admin

  def agreement_confirmed
    object.agreement_confirmed_at ? true : false
  end

end
