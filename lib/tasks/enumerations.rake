namespace :enumerations do

  desc "create new enumeration"
  task :create, [:name] => :environment do |t, args|
    if args[:name]
      Enumeration.find_or_create_by(name: args[:name])
    end
  end

  desc "create new enumeration value"
  task :create_value, [:enumeration_id, :value, :value_short] => :environment do |t, args|
    params = { enumeration_id: args[:enumeration_id], value: args[:value], value_short: args[:value_short] }
    EnumerationValue.find_or_create_by(params)
  end

end
