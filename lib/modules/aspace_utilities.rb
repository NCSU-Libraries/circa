module AspaceUtilities

  def self.included receiver
    receiver.extend self
  end


  # Query ArchivesSpace Solr index (currently unused but available if needed)
  # Ensure that archivesspace_solr_port and archivesspace_solr_path are defined in application.yml
  def aspace_solr_query(query, params={})
    solr_url = "http://#{ENV['archivesspace_host']}:#{ENV['archivesspace_solr_port']}#{ENV['archivesspace_solr_core_path']}"
    @solr = RSolr.connect :url => solr_url
    @solr_params = {:q => query }
    @solr_params.merge! params
    @response = @solr.get 'select', :params => @solr_params
  end


  # Perform a GET request to ArchivesSpace
  # Returns response body as Ruby hash, or nil
  def aspace_api_get(uri, params={}, headers={})
    @a = ArchivesSpaceApiUtility::ArchivesSpaceSession.new

    response = @a.get(uri, params, headers)

    # Response code 412 from ArchivesSpace API indicates a problem with the authenticated session
    # The cause of this is unclear, but re-connecting seems to address the problem (2017-02-15)
    if response.code.to_i == 412
      @a = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      response = @a.get(uri, params, headers)
    end

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      nil
    end
  end

end
