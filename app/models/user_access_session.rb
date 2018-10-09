class UserAccessSession < ApplicationRecord

  belongs_to :user
  belongs_to :access_session


  # Load custom concern if present - methods in concern take precidence
  begin
    include UserAccessSessionCustom
  rescue
  end

end
