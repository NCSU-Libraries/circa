namespace :special do

  desc "create order for rachel.robison@usu.edu"
  task :robinson_order => :environment do |t|
    user_id = 4201
    order_params = {
      access_date_start: Date.parse('2019-07-10'),
      access_date_end: Date.parse('2019-08-06'),
      confirmed: true,
      open: false,
      location_id: 28,
      order_sub_type_id: 4
    }

    if order = Order.create!(order_params)
      order_user = OrderUser.create!(order_id: order.id, user_id: user_id, primary: true)
    end

    puts "created Order #{order.id} and OrderUser #{order_user.id}"
  end


  task :robinson_checkouts => :environment do |t|
    require 'csv'
    @a = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
    csv_path = Pathname.new(Rails.root) + 'tmp/robinson_checkouts.csv'
    order = Order.find 10933

    def get_location_id(uri)
      response = @a.get(uri)
      data = JSON.parse(response.body)
      if location = data["container_locations"].first
        location_ref = location["ref"]
        if location = Location.find_by(uri: location_ref)
          location.id
        else
          nil
        end
      else
        nil
      end
    end

    CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
      item = Item.find_by(uri: row[:top_container_uri])

      if !item
        item_atts = {
          resource_title: row[:resource_title],
          resource_identifier: row[:resource_identifier],
          resource_uri: row[:resource_uri],
          container: row[:container],
          uri: row[:top_container_uri]
        }

        if location_id = get_location_id(row[:top_container_uri])
          item_atts.merge!({
            permanent_location_id: location_id,
            current_location_id: location_id
          })
        end

        item = Item.create!(item_atts)
        puts "created new Item (#{item.id})"
      else
        puts "using existing Item (#{item.id})"
      end

      item_order_atts = {
        item_id: item.id,
        order_id: 10933
      }

      item_order = ItemOrder.find_by(item_order_atts)
      if !item_order
        item_order_atts[:user_id] = 1
        ItemOrder.create!(item_order_atts)
      end

      session_atts = {
        item_id: item.id,
        order_id: order.id,
        start_datetime: DateTime.parse(row[:start_datetime]),
        end_datetime: DateTime.parse(row[:end_datetime])
      }

      puts "Creating access session for user based imported data"
      access_session = AccessSession.find_or_create_by(session_atts)
      puts access_session.inspect

      puts "creating UserAccessSession"
      UserAccessSession.find_or_create_by({
        user_id: row[:user_id],
        access_session_id: access_session.id
      })
      puts UserAccessSession.inspect

    end
  end

end
