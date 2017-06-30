namespace :search_index do

  desc "full clean index"
  task :full_clean => :environment do |t, args|
    SearchIndex.wipe_index
    SearchIndex.execute_full
  end

  desc "full index"
  task :full => :environment do |t, args|
    SearchIndex.execute_full
  end

end
