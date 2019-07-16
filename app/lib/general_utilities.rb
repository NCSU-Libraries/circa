module GeneralUtilities

  def nil_or_empty?(value)
    if value.nil? || (value.respond_to?(:empty?) && value.empty?)
      true
    end
  end

  # Log message and output to stdout
  def log_info(message)
    Rails.logger.info message
    # output to stdout for visibility into running background jobs
    puts "#{DateTime.now.to_s} - #{message}"
  end

  # Log error and output to stdout
  def log_error(message)
    Rails.logger.error message
    # output to stdout for visibility into running background jobs
    puts "#{DateTime.now.to_s} - ERROR: #{message}"
  end

end
