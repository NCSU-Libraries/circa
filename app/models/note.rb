class Note < ApplicationRecord

  belongs_to :noted, polymorphic: true

  # Load custom concern if present - methods in concern override those in model
  begin
    include NoteCustom
  rescue
  end

end
