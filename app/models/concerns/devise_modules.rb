require 'active_support/concern'

module DeviseModules
  extend ActiveSupport::Concern

  included do

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

  end
end
