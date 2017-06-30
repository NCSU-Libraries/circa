namespace :solr do

  desc "reload circa core"
  task :reload_core => :environment do |t, args|
    cmd = "curl http://#{ ENV['solr_host'] }:#{ ENV['solr_port'] }/solr/admin/cores?action=RELOAD&core=#{ ENV['solr_core_name'] }"
    `#{cmd}`
  end

end
