class CourseReserve < ApplicationRecord

  belongs_to :order
  has_one :primary_user, class_name: 'User'


  # Load custom concern if present - methods in concern override those in model
  begin
    include CourseReserveCustom
  rescue
  end

end
