class UserRole < ActiveRecord::Base

  # app/models/concerns/ref_integrity.rb
  include RefIntegrity

  has_many :users

  validates :name, uniqueness: true

  before_create do
    self.level = self.level || UserRole.default_level
  end


  # returns lowest role (the one with the highest level value)
  def self.lowest
    UserRole.order('level DESC').first
  end


  def is_admin?
    level <= 1
  end


  def self.default_level
    self.lowest ? self.lowest.level + 10 : 10
  end


  def self.merge(from_id, into_id)
    from_role = self.find(from_id)
    into_role = self.find(into_id)
    if from_role.is_admin? || into_role.is_admin?
      raise CircaExceptions
    else
      User.where(user_role_id: from_id).each do |u|
        u.update_attributes(user_role_id: into_id)
      end
    end
  end


end
