require 'active_support/concern'

module UserCustom
  extend ActiveSupport::Concern

  included do

    # Devise configuration
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    # add custom methods, validators, etc.

  end

end
