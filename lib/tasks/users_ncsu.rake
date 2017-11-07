namespace :users do

  desc "create user with Unity ID"
  task :unity_create, [:unity_id] => :environment do |t, args|
    if args[:unity_id]
      User.create_from_ldap(args[:unity_id], options)
    end
  end


  desc "get ldap record"
  task :ldap_record, [:unity_id] => :environment do |t, args|
    if args[:unity_id]
      User.attributes_from_ldap(args[:unity_id])
    end
  end

end
