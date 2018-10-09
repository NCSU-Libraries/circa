module CatalogApiSpecSupport

  def catalog_request_item
    ActiveSupport::HashWithIndifferentAccess.new({
      "recordSpec" => "NCSU2499528",
      "library" => "SPECCOLL",
      "barcode" => "S02830408P",
      "displayLibrary" => "Special Collections (D.H. Hill)",
      "sirsiLibrary" => "SPECCOLL",
      "originalLocationCode" => "SPECCOLL-FACULTYPUB",
      "locationCode" => "SPECCOLL-FACULTYPUB",
      "location" => "Off-site Shelving",
      "displayLocation" => "Faculty Publications",
      "callScheme" => "LC",
      "callNumber" => "NA2750 .B753 2011",
      "format" => "BOOKNOCIRC",
      "periodical" => false,
      "numHolds" => 0,
      "status" => "Available (Library use only)",
      "simpleStatus" => "available",
      "usageRestriction" => "In Library Use Only",
      "reserveControlRecord" => "0",
      "source" => "SIRSI",
      "available" => true,
      "monographicSeries" => false,
      "bookBot" => false,
      "checkedOut" => false,
      "reserves" => false,
      "microform" => false,
      "govDoc" => false,
      "demandDriven" => false,
      "libraryUseOnly" => true,
      "ebook" => false,
      "requestable" => true,
      "baseRequestURL" => "/request/NCSU2499528",
      "offsite" => false,
      "summaryHoldings" => "",
      "manuscript" => false,
      "onOrder" => false,
      "inReferenceCollection" => false,
      "reserveStatus" => false,
      "itemRequestURL" => "/request/NCSU2499528#S02830408P",
      "researcherInaccessible" => true,
      "kindleBook" => false,
      "specialCollections" => true
    })
  end

end
