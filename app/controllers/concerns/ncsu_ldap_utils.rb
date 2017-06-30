require 'active_support/concern'

module NCSULdapUtils
  extend ActiveSupport::Concern

  included do

    def attributes_from_ldap
      @uid = URI.unescape( params[:uid] )

      existing = User.find_by_unity_id(@uid)

      if existing
        raise CircaExceptions::BadRequest, "User with Unity ID #{ @uid } already exists."
      else
        attributes = User.attributes_from_ldap(@uid)
        render json: { user: attributes }
      end
    end

  end

end
