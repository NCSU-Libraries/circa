class AccessSession < ApplicationRecord

  include CircaExceptions
  include SolrDoc

  belongs_to :item
  belongs_to :order
  has_many :user_access_sessions
  has_many  :users, through: :user_access_sessions

  before_create do
    self.start_datetime = DateTime.now
    self.active = true
    self.class.check_in_use(self)
  end

  before_save do
    self.active = self.end_datetime.nil? ? true : false
    true
  end


  def self.create_with_users(attributes)
    users = attributes.delete(:users)
    if !users
      raise ActiveRecord::ActiveRecordError, 'create_with_users requires users'
    else

      ### REMOVED 2018-09-28
      ### constraint on agreement_confirmed_at now only enforced on front end
      ### left here temporarily for reference

      # filter_users = lambda do |usrs|
      #   filtered = []
      #   usrs.each do |u|
      #     user = User.find(u['id'])
      #     if user.agreement_confirmed_at
      #       filtered << u
      #     end
      #   end
      #   return filtered
      # end

      # users = filter_users.call(users)

      # if users.empty?
      #   raise CircaExceptions::BadRequest, 'None of the submitted users is eligible'
      # else
      #   session = create!(attributes)
      #   users.each { |u| session.user_access_sessions.create!(user_id: u['id']) }
      #   session
      # end

      session = create!(attributes)
      users.each { |u| session.user_access_sessions.create!(user_id: u['id']) }
      session
    end
  end


  def close
    update_attributes(end_datetime: DateTime.now, active: false)
  end


  def self.check_in_use(record)
    existing = AccessSession.where(item_id: record.item_id, active: true).first
    if existing
      raise CircaExceptions::BadRequest
    end
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include AccessSessionCustom
  rescue
  end

end
