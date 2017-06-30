namespace :enumerations do


  ## Configuration ##

  # The hash defined here specify enumerations and enumeration values to be used within the system
  # Keys are enumeration types
  # Values are arrays of enumeration values, which can either be a single string
  #   or an array containing 2 strings
  # If a single string is provided, this value will be used both for the display value and short ('machine-readable') value
  # If an array is provided, the first string will be used as the display value and the second will be used as the short value

  def default_enumerations
    {
      'patron_type' => [
        ['faculty','faculty'],
        ['graduate student','graduate_student'],
        ['undergraduate','undergraduate'],
        ['staff','staff'],
        ['visiting researcher (undergraduate)','visiting_researcher_undergraduate'],
        ['visiting researcher (graduate student)','visiting_researcher_graduate_student'],
        ['visiting researcher (college/university faculty)','visiting_researcher_faculty'],
        ['visiting researcher (other/independent)','visiting_researcher']
      ],

      'location_source' => [
        ['ArchivesSpace','archivesspace'],
        ['Circa','circa'],
        ['Catalog','catalog'],
      ]

    }
  end

  ## END - Configuration ##


  desc "populate default enumerations and values"
  task :populate => :environment do |t|
    default_enumerations.each do |enumeration, values|
      e = Enumeration.find_by_name(enumeration)

      if !e
        e = Enumeration.create!(name: enumeration)
        puts "Enumeration '#{enumeration}' created"
      else
        puts "Enumeration '#{enumeration}' exists"
      end

      values.each do |v|
        if (v.kind_of?(Array))
          value_short = v[1]
          attributes = { value: v[0], value_short: value_short, enumeration_id: e.id }
        else
          value_short = v.downcase
          attributes = { value: v, value_short: v.downcase, enumeration_id: e.id }
        end
        value = EnumerationValue.find_by(value_short: value_short, enumeration_id: e.id)

        if !value
          value = EnumerationValue.create!(attributes)
          puts "EnumerationValue '#{v}' for Enumeration '#{enumeration}' created"
        else
          puts "EnumerationValue '#{v}' for Enumeration '#{enumeration}' exists - updating"
          value.update_attributes(attributes)
        end
      end

    end
  end


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
