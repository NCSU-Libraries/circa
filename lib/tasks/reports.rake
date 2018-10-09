namespace :reports do

  task :access_sessions, [:start, :end] => :environment do |t, args|
    start_date = args[:start]
    end_date = args[:end]

    where = "start_datetime BETWEEN '#{start_date}' AND '#{end_date}'"

    def process_record(r)
      d = {}
      d[:users] = r.users.map { |u| u.email }.join('; ')
      d[:date] = r.start_datetime ? r.start_datetime.strftime('%Y-%m-%d') : nil
      d[:start_date] = r.start_datetime ? r.start_datetime.strftime('%Y-%m-%d') : nil
      d[:end_date] =  r.end_datetime ? r.end_datetime.strftime('%Y-%m-%d') : nil
      d[:day] = r.start_datetime ? r.start_datetime.strftime("%A") : nil
      d[:start_time] = r.start_datetime ? r.start_datetime.localtime.strftime("%I:%M %p") : nil
      d[:end_time] = r.end_datetime ? r.end_datetime.localtime.strftime("%I:%M %p") : nil
      d[:note] = r.end_datetime ? nil : "missing check in"

      if d[:start_date] != d[:end_date]
        d[:end_time] = nil
        d[:note] = "missing/late check in"
      end
      d
    end

    fields = [:date, :users, :day, :start_time, :end_time, :note]

    report_filename = "access_sessions_#{ start_date }-#{ end_date }.csv"
    report_path = Rails.root.join('reports',report_filename)
    report = File.new(report_path,'w')
    report.puts fields.map { |f| f.to_s }.join(",")

    AccessSession.where(where).order('start_datetime ASC').includes(:users).find_each do |r|
      session = process_record(r)
      row = []
      fields.each do |f|
        row << session[f]
      end
      report.puts row.join(',')
    end

    report.close

  end


  task :unique_visits, [:start, :end] => :environment do |t, args|
    start_date = args[:start]
    end_date = args[:end]

    where = "start_datetime BETWEEN '#{start_date}' AND '#{end_date}'"


    report_data = {}


    fields = [:date, :day, :email, :start_time, :end_time]

    report_filename = "unique_visits_#{ start_date }-#{ end_date }.csv"
    report_path = Rails.root.join('reports',report_filename)
    report = File.new(report_path,'w')
    report.puts fields.map { |f| f.to_s }.join(",")

    AccessSession.where(where).order('start_datetime ASC').includes(:users).find_each do |r|
      start_datetime = r.start_datetime
      end_datetime = r.end_datetime

      start_date = start_datetime ? start_datetime.strftime('%Y-%m-%d') : nil
      end_date = end_datetime ? end_datetime.strftime('%Y-%m-%d') : nil

      if start_date

        report_data[start_date] ||= {}
        report_data[start_date][:day] ||= start_datetime.strftime("%A")
        report_data[start_date][:users] ||= {}

        r.users.each do |u|
          email = u.email
          report_data[start_date][:users][email] ||= {}
          report_data[start_date][:users][email][:start_datetime] ||= start_datetime

          if report_data[start_date][:users][email][:start_datetime] > start_datetime
            report_data[start_date][:users][email][:start_datetime] = start_datetime
          end

          if end_datetime && (start_date == end_date)
            report_data[start_date][:users][email][:end_datetime] ||= end_datetime
            if report_data[start_date][:users][email][:end_datetime] < end_datetime
              report_data[start_date][:users][email][:end_datetime] = end_datetime
            end
          end

        end
      end
    end


    # process report_data
    rows = []
    report_data.each do |date, data|
      day = data[:day]
      data[:users].each do |email, udata|
        start_time = udata[:start_datetime].strftime("%I:%M %p")
        end_time = udata[:end_datetime] ? udata[:end_datetime].strftime("%I:%M %p") : nil
        rows << [date, day, email, start_time, end_time]
      end
    end

    rows.each do |row|
      report.puts row.join(',')
    end

    report.close

  end

end
