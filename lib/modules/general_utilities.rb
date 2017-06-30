module GeneralUtilities

  def nil_or_empty?(value)
    if value.nil? || (value.respond_to?(:empty?) && value.empty?)
      true
    end
  end

end
