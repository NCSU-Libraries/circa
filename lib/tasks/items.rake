namespace :items do

  desc "update all item attributes from source"
  task :update_all_from_source => :environment do |t, args|
    puts "updating #{ Item.count } Items"
    Item.find_each do |i|
      print '.'
      i.update_from_source
    end
  end

end
