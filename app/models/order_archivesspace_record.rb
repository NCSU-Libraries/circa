class OrderArchivesspaceRecord < ApplicationRecord

  belongs_to :order

  # Load custom concern if present - methods in concern override those in model
  begin
    include OrderArchivesspaceRecordCustom
  rescue
  end

end
