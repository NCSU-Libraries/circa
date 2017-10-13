class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :wolftech_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include EnumerationUtilities
  include RefIntegrity
  include VersionsSupport
  # include UserRoles
  include SolrDoc

  include NCSULdap
  require 'campus-ldap.rb'

  belongs_to :user_role
  has_many :order_users
  has_many :item_orders
  has_many :notes, as: :noted

  has_many :orders, through: :order_users do
    def open
      where(open: true)
    end
    def completed
      where(open: false)
    end
  end

  # has_many :open_orders, through: :order_users, class_name: 'Order', where: { open: }
  has_many :order_assignments
  has_many :assigned_orders, through: :order_assignments, source: :order
  has_many :notes, as: :noted

  has_many :user_access_sessions
  has_many :access_sessions, through: :user_access_sessions
  has_many :accessed_items, through: :access_sessions

  has_many :state_transitions

  has_paper_trail

  before_destroy :deletable?

  before_create do
    if self.user_role_id.blank?
      self.user_role_id = UserRole.lowest.id
    end
  end

  before_save do
    if self.display_name.blank?
      self.display_name = "#{self.first_name} #{self.last_name}"
    end
  end

  validates :email, presence: true, uniqueness: true

  # Setter and getter used to assign/fetch current_user to/from User
  # see: https://amitrmohanty.wordpress.com/2014/01/20/how-to-get-current_user-in-model-and-observer-rails/
  def self.current
    RequestStore.store[:user]
  end


  def self.current=(user)
    RequestStore.store[:user] = user
  end


  def self.staff_patron_type_id
    get_enumeration_value_id('staff', 'patron_type')
  end


  def open_orders
    orders.open
  end


  def completed_orders
    orders.completed
  end


  def patron_type
    get_enumeration_value(patron_type_id)
  end


  def has_active_access_session
    access_sessions.where(active: true).count > 0
  end


  # user_role methods

  def roles
    assignable_roles.map { |r| r.name }
  end


  def role
    user_role.name
  end


  def assign_role(new_user_role)
    update_attributes(user_role_id: new_user_role.id)
  end


  def is_admin?
    admin_role = UserRole.find_by_name('admin')
    # adding condition here for nil user_role to support testing
    if !user_role
      false
    else
      user_role.level <= admin_role.level
    end
  end


  # alias for is_admin?, used by serializers
  def is_admin
    is_admin?
  end


  # def has_role?(r)
  #   roles.include?(r.to_sym)
  # end


  def assignable_roles
    roles = []
    UserRole.order(:level).each do |ur|
      if ur.level >= user_role.level
        roles << ur
      end
    end
    roles
  end


  def can_assign_role?(user_role_id)
    assignable_roles.map { |r| r.id }.include?(user_role_id.to_i)
  end

end
