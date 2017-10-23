namespace :items do

  desc "update all item attributes from source"
  task :update_all_from_source => :environment do |t, args|
    puts "updating #{ Item.count } Items"
    Item.find_each do |i|
      print '.'
      i.update_from_source
    end
  end

  desc "get new ArchivesSpace top container URI"
  task :populate_top_container_uris => :environment do |t, args|
    puts "getting top container URIs from ArchivesSpace"
    Item.add_archivesspace_top_container_uris
  end

end
