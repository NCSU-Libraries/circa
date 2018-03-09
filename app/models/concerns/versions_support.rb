require 'active_support/concern'

module VersionsSupport
  extend ActiveSupport::Concern

  included do

    def created_by_user
      v = versions.first
      if v
        user_id = v.whodunnit.to_i
        User.find_by_id(user_id)
      end
    end

    def last_updated_by_user
      v = versions.last
      if v
        user_id = v.whodunnit.to_i
        User.find_by_id(user_id)
      end
    end

  end

end
