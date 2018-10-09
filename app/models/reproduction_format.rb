class ReproductionFormat < ApplicationRecord

  has_many :reproduction_specs


  # Load custom concern if present - methods in concern override those in model
  begin
    include ReproductionFormatCustom
  rescue
  end

end
