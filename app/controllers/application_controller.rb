class ApplicationController < ActionController::Base

  include ApiUtilities

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # force_ssl if: :user_signed_in?

  before_action :authenticate_user!

  # before_filter :store_location


  # Assign current_user to User to use it outside of controllers
  # see: https://amitrmohanty.wordpress.com/2014/01/20/how-to-get-current_user-in-model-and-observer-rails/
  before_filter :set_current_user

  def set_current_user
    User.current = current_user
  end

  def verified_request?
    # For Rails 4.2 and above
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    # OLD VERSION - Rails 4.1 and below
    # super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  # def store_location
  #   # store last url - this is needed for post-login redirect to whatever the user last visited.
  #   return unless request.get?
  #   if (request.path != "/users/sign_in" &&
  #       request.path != "/users/sign_up" &&
  #       request.path != "/users/password/new" &&
  #       request.path != "/users/password/edit" &&
  #       request.path != "/users/confirmation" &&
  #       request.path != "/users/sign_out" &&
  #       !request.xhr?) # don't store ajax calls
  #     session[:previous_url] = request.fullpath
  #   end
  # end


  # def after_sign_in_path_for(resource)
  #   session[:previous_url] || root_path
  #   puts "TEST OF session[:previous_url]"
  #   puts session[:previous_url]
  # end


  private



end
