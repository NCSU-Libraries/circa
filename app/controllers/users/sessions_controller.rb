class Users::SessionsController < Devise::SessionsController

# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   begin
  #     user = User.where(email: params[:user][:email]).first
  #     if user && user.inactive
  #       redirect_to '/users/sign_in', alert: "User with email #{ user.email } is no longer active."
  #     else
  #       super
  #     end
  #   rescue Exception => e
  #     flash[:alert] = e
  #   end
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
