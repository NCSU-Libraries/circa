namespace :circa do

  desc "populate database with default values"
  task :setup => :environment do |t, args|
    Rake::Task['user_roles:populate'].invoke
    Rake::Task['order_types:populate'].invoke
    Rake::Task['users:create_admin'].invoke
  end

end
