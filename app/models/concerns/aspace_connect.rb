require 'active_support/concern'

module AspaceConnect
  extend ActiveSupport::Concern

  included do
    require 'archivesspace-api-utility/helpers'
    include AspaceUtilities
    include ArchivesSpaceApiUtility
    include ArchivesSpaceApiUtility::Helpers
  end

end
