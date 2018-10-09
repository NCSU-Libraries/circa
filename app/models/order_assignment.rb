class OrderAssignment < ApplicationRecord

  belongs_to :user
  belongs_to :order

  # Load custom concern if present - methods in concern override those in model
  begin
    include OrderAssignmentCustom
  rescue
  end

end
