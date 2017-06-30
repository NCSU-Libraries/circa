class CourseReserve < ActiveRecord::Base

  belongs_to :order
  has_one :primary_user, class_name: 'User'

end
