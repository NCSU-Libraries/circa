module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    serialize :association_data
  end
end
