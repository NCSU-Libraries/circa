require 'active_support/concern'

module UsersControllerCustom
  extend ActiveSupport::Concern

  included do


    before_action :verify_unity_id, only: [ :check_in ]


    def create_from_ldap
      @user = User.create_from_ldap(params[:unity_id])
      render json: @user
    end


    def attributes_from_ldap
      @user_attrs = User.attributes_from_ldap(params[:unity_id])
      render json: { user: @user_attrs }
    end


    private

    def verify_unity_id
      if !params[:unity_id]
        raise CircaExceptions::BadRequest, "Unity ID is required"
      end
    end


  end

end
