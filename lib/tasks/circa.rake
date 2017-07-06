namespace :circa do

  desc "generate secrets.yml"
  task :generate_secrets do |t|
    require 'securerandom'
    f = File.new('config/secrets.yml', 'w')
    f.puts "# Be sure to restart your server when you modify this file."
    f.puts
    f.puts "# Your secret key is used for verifying the integrity of signed cookies."
    f.puts "# If you change this key, all old signed cookies will become invalid!"
    f.puts
    f.puts "# Make sure the secret is at least 30 characters and all random,"
    f.puts "# no regular words or you'll be exposed to dictionary attacks."
    f.puts "# You can use `rake secret` to generate a secure secret key."
    f.puts
    f.puts "# Make sure the secrets in this file are kept private"
    f.puts "# if you're sharing your code publicly."
    f.puts
    f.puts "development:"
    f.puts "  secret_key_base: " + SecureRandom.hex(64)
    f.puts
    f.puts "test:"
    f.puts "  secret_key_base: " + SecureRandom.hex(64)
    f.puts
    f.puts "staging:"
    f.puts "  secret_key_base: " + SecureRandom.hex(64)
    f.puts
    f.puts "# Do not keep production secrets in the repository,"
    f.puts "# instead read values from the environment."
    f.puts "production:"
    f.puts ' secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>'
    f.close
  end

end
