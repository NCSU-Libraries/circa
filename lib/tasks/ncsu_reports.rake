namespace :ncsu_reports do

  task :open_orders => :environment do |t, args|
    report_filepath = Rails.root.to_s + "/tmp/open_orders_report.txt"
    f = File.new(report_filepath, 'w')

    headers = ['order/item','state','num. open orders', 'item at permanent location', 'current location','permanent location',"item reached 'ready_at_temporary_location' state? for this order"]
    header_row = headers.join("\t")
    f.puts header_row

    Order.where(open: true).each do |o|
      o_row = "ORDER #{ o.id }\t"
      o_row += o.current_state.to_s

      f.puts o_row

      o.items.each do |i|
        i_row = ""
        i_row += "#{i.resource_identifier}, #{i.container} (#{ i.id })\t"
        i_row += i.current_state.to_s + "\t"
        i_row += i.open_orders.length.to_s + "\t"
        i_row += (i.permanent_location_id == i.current_location_id).to_s + "\t"
        i_row += i.current_location ? (i.current_location.title + "\t") : "--\t"
        i_row += i.permanent_location ? (i.permanent_location.title + "\t") : "--\t"
        i_row += i.state_reached_for_order(:ready_at_temporary_location, o.id).to_s
        f.puts i_row
      end

      f.puts
    end

    f.close

    puts "Report:"
    puts report_filepath
  end

end
