namespace :orders do

  desc "close applicable orders"
  task :close_all_finished, [:user_email] => :environment do |t, args|
    if args[:user_email]
      user = User.find_by(email: args[:user_email])
      if user
        metadata = { user_id: user.id }
        Order.find_each do |o|
          if o.finished? && o.order_type.name != 'reproduction'
            puts "closing Order #{o.id}..."
            o.trigger(:close, metadata)
          end
        end
      end
    end
  end

end
