module CircaExceptions
  class BadRequest < StandardError; end
  class Forbidden < StandardError; end
  class ReferentialIntegrityConflict < StandardError; end
end
