class StateTransition < ApplicationRecord

  belongs_to :record, polymorphic: true
  belongs_to :user

  serialize :metadata

end
