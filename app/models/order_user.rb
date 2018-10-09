class OrderUser < ApplicationRecord

  belongs_to :order
  belongs_to :user

  # Load custom concern if present - methods in concern override those in model
  begin
    include OrderUserCustom
  rescue
  end

end
