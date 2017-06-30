namespace :locations do

  desc "populate facility values"
  task :populate_facility, [:id] => :environment do |t, args|
    circa_source_id = Location.circa_location_source_id
    archivesspace_source_id = Location.archivesspace_location_source_id
    catalog_source_id = Location.catalog_location_source_id

    update_facility = Proc.new do |location|
      if !location.facility && location.source_id != circa_source_id
        case location.source_id
        when archivesspace_source_id
          location.update_from_archivesspace
        when catalog_source_id
          facility = nil
          case location.catalog_item_data['locationCode']
          when 'SPECCOLL-STACKS','SPECCOLL-FACULTYPUB','SPECCOLL-REF'
            facility = 'D. H. Hill'
          end
          location.update_attributes(facility: facility)
        end
        location.reload
        puts "Location #{ location.id } - #{ location.facility ? location.facility : 'nil' }"
      end

    end

    if args[:id]
      loc = Location.find_by(id: args[:id])
      if loc
        update_facility.call(loc)
      end
    else
      Location.where('facility is null').each do |l|
        update_facility.call(l)
      end
    end

  end

end
