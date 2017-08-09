source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.8'
gem 'rake'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.3.18'

# Make SQLite available for development
gem 'sqlite3'

gem 'devise'

gem 'archivesspace-api-utility', git: "https://github.com/trevorthornton/archivesspace-api-utility.git"


gem 'paper_trail'
gem 'formtastic'
# Using 0.10.0.rc3
gem 'active_model_serializers', git: "https://github.com/rails-api/active_model_serializers.git", branch: "0-10-stable"


gem 'sprockets-rails', '~> 3.0.2', :require => 'sprockets/railtie'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'compass-rails'
gem 'foundation-rails', '< 6.0'
gem 'modernizr-rails'
gem 'font-awesome-sass'
gem 'will_paginate'
gem 'foundation-will_paginate'


# NCSU only
gem 'devise_wolftech_authenticatable', git: "git@github.ncsu.edu:NCSU-Libraries/devise_wolftech_authenticatable.git"
gem 'ncsu_catalog_api_client', git: "git@github.ncsu.edu:trthorn2/ncsu_catalog_api_client.git"
# END - NCSU only


# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Use Bower to manage front-end assets
gem 'bower-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rsolr'

gem 'request_store'

gem 'resque'
gem 'resque-scheduler'

gem 'whenever', :require => false

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

end


group :development, :test do
  gem 'rspec-rails', '>= 3.0'
  gem 'factory_girl_rails', ">= 4.0", :require => false
  gem 'database_cleaner', ">= 1.0.0"

  gem "jasmine", github: "pivotal/jasmine-gem"
  gem 'sinon-rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Capistrano and friends
  gem 'capistrano', '~> 3.1'
  # rails specific capistrano funcitons
  gem 'capistrano-rails', '~> 1.1'
  # integrate bundler with capistrano
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-linked-files', require: false

  gem 'quiet_assets'
end
