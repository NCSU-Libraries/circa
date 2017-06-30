class StaticPagesController < ApplicationController

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def index
    if !:user_signed_in?
      redirect_to '/users/sign_in'
    end
  end

end
