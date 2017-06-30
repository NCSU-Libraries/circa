class UserAccessSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :access_session
end
