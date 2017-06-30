class Note < ActiveRecord::Base

  belongs_to :noted, polymorphic: true

end
