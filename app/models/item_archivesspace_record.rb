class ItemArchivesspaceRecord < ApplicationRecord

  belongs_to :item


  # Load custom concern if present - methods in concern override those in model
  begin
    include ItemArchivesspaceRecordCustom
  rescue
  end

end
