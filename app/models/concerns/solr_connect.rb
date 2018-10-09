require 'active_support/concern'

module SolrConnect
  extend ActiveSupport::Concern

  included do

    # Solr URL - constructed here using ENV vars declared on initialization
    def self.solr_url
      protocol = ENV['solr_https'] ? 'https://' : 'http://'
      port = ENV['solr_port'] ? ":#{ENV['solr_port']}" : ''
      "#{protocol}#{ENV['solr_host']}#{port}#{ENV['solr_core_path']}"
    end

    @@solr_url = self.solr_url

  end
end
