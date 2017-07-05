namespace :users do

  desc "create user with Unity ID"
  task :unity_create, [:unity_id, :role] => :environment do |t, args|
    if args[:unity_id]
      options = { role: args[:role] }
      User.create_from_ldap(args[:unity_id], options)
    end
  end


  desc "create generic admin user for initial "
  task :create_admin => :environment do |t, args|
    admin_role = UserRole.where(name: 'admin').first
    if admin_role
      existing_admin_user = User.where(user_role_id: admin_role.id).first
      if !existing_admin_user
        user = User.create!(email: 'admin@circa', password: 'circa_admin', user_role_id: admin_role.id)
        puts "Admin user created. email: admin@circa, password: circa_admin"
      else
        puts "An admin user already exists with email '#{ existing_admin_user.email }'"
      end
    else
      puts "Admin role does not yet exist. Run 'rake user_roles:populate'"
    end
  end


  # This is a one-time task to be run after migrations to update user_role model
  desc "migrate to new user_role model"
  task :migrate_user_roles => :environment do |t, args|

    if !User.new.respond_to?(:role_old)
      puts "Task cannot be run because column 'role_old' does not exist on table 'users'"
    else

      # reload solr core
      `curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=circa"`

      User.find_each do |u|
        if u.role_old
          role = UserRole.find_by_name(u.role_old)
          if !role
            levels = {
              'admin' => 1,
              'staff' => 10,
              'assistant' => 20,
              'patron' => 30
            }
            role = UserRole.create(name: u.role_old, level: levels[u.role_old])
          end
          u.update_attributes(user_role_id: role.id)
        end
      end

    end
  end


end
