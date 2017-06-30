#lib/tasks/resque.rake

require 'resque/tasks'
require 'resque/scheduler/tasks'

# I GOT THIS FROM HERE:
# http://drou.in/post/55836815291/how-to-start-and-restart-resque-workers-with

namespace :resque do

  task :work

  task :setup => :environment do
    Resque.before_fork = Proc.new do |job|
      ActiveRecord::Base.connection.disconnect!
    end
    Resque.after_fork = Proc.new do |job|
      ActiveRecord::Base.establish_connection
    end
  end

  desc "Restart running workers"
  task :restart_workers, [:num_workers] => :environment do |t, args|
    kill_unregistered_workers
    stop_workers
    count = args[:num_workers].to_i
    count = count > 0 ? count : 1
    run_worker("*", count)
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    stop_workers
  end


  desc "Start workers"
  task :start_workers, [:num_workers] => :environment do |t, args|
    count = args[:num_workers].to_i || 1
    run_worker("*", count)
  end


  desc "Kill processes associated with unregistered workers"
  task :kill_unregistered_workers => :environment do
    kill_unregistered_workers
  end


  desc "show_workers"
  task :show_workers => :environment do
    show_workers
  end


  # def store_pids(pids, mode)
  #   pids_to_store = pids
  #   pids_to_store += read_pids if mode == :append

  #   # Make sure the pid file is writable.
  #   File.open(File.expand_path('tmp/pids/resque.pid', Rails.root), 'w') do |f|
  #     f <<  pids_to_store.join(',')
  #   end
  # end


  # def read_pids
  #   pid_file_path = File.expand_path('tmp/pids/resque.pid', Rails.root)
  #   return []  if ! File.exists?(pid_file_path)

  #   File.open(pid_file_path, 'r') do |f|
  #     f.read
  #   end.split(',').collect {|p| p.to_i }
  # end


  def show_workers
    puts "#{ Resque.workers.length } registered workers:"
    Resque.workers.each do |w|
      puts "PID: #{ w.pid }, status: #{ w.state }"
    end
  end


  # kills registered workers once they go idle
  def stop_workers
    workers = Resque.workers
    until workers.empty? do
      workers.each_index do |i|
        w = workers[i]
        pid = w.pid
        if w.idle?
          workers.delete_at(i)
          puts "Stopping worker #{pid}..."
          w.unregister_worker
          system("kill #{pid}")
        else
          puts "Waiting for worker #{pid} to go idle..."
          sleep 1
          next
        end
      end
    end
  end


  # def stop_workers
  #   pids = read_pids

  #   if pids.empty?
  #     puts "No workers to kill"
  #   else
  #     syscmd = "kill -s QUIT #{pids.join(' ')}"
  #     puts "$ #{syscmd}"
  #     `#{syscmd}`
  #     store_pids([], :write)
  #   end
  # end


  # I feel really bad about this method name :(
  # it's accurate w/r/t what it does, but it's also just wrong
  def kill_unregistered_workers
    registered_worker_pids = Resque.workers.map { |w| w.pid.to_s }
    r = Resque.workers[0] || Resque::Worker.new('*')
    unregistered_worker_pids = r.worker_pids - registered_worker_pids
    unregistered_worker_pids.each do |pid|
      system("kill #{ pid }")
    end
  end


  # Start worker(s) with proper env vars and output redirection
  def run_worker(queue, count = 1)
    puts "Starting #{count} worker(s) with QUEUE: #{queue}"

    ##  make sure log/resque_err, log/resque_stdout are writable.
    ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err.log").to_s, "a"],
                            :out => [(Rails.root + "log/resque_stdout.log").to_s, "a"]}
    env_vars = {"QUEUE" => queue.to_s, 'RAILS_ENV' => Rails.env.to_s}

    # pids = []
    count.times do
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
      puts "Started worker with PID #{ pid }"

      # pids << pid
    end

    # store_pids(pids, :append)
  end


end
