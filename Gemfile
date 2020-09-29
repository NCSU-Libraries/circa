source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.3'
gem 'rake'

# Use mysql as the database for Active Record
gem 'mysql2'

# Make SQLite available for development
gem 'sqlite3', '~> 1.3.6'

gem "devise", ">= 4.7.1"
gem 'net-ldap'

gem 'archivesspace-api-utility', git: "https://github.com/NCSU-Libraries/archivesspace-api-utility.git"

gem 'paper_trail', '>=9.2.0'
# gem 'paper_trail-association_tracking'

# Using 0.10.0.rc3
# gem 'active_model_serializers', git: "https://github.com/rails-api/active_model_serializers.git", branch: "0-10-stable"

gem 'sprockets-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.7'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

gem 'compass-rails'
gem 'foundation-rails', '< 6.0'
gem 'modernizr-rails'
gem 'font-awesome-sass'
gem 'will_paginate'
gem 'foundation-will_paginate'

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
gem 'jbuilder'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rsolr'

gem 'request_store'

gem 'resque'
gem 'resque-scheduler'

gem 'whenever', :require => false

# security vulnerability fix: http://nvd.nist.gov/vuln/detail/CVE-2018-3760
gem 'sprockets', '~> 3.7.2'

# security vulnerability fix: https://nvd.nist.gov/vuln/detail/CVE-2018-16468
gem "loofah", ">= 2.3.1"

# security vulnerabilities fix: https://nvd.nist.gov/vuln/detail/CVE-2020-8184
gem "rack", ">= 2.2.3"

# security vulnerabilities fix: https://nvd.nist.gov/vuln/detail/CVE-2018-16477
gem "activestorage", ">= 5.2.1.1"

# security vulnerabilities fix - https://nvd.nist.gov/vuln/detail/CVE-2019-5477
gem "nokogiri", ">= 1.10.4"

# security vulnerabilities fix - https://nvd.nist.gov/vuln/detail/CVE-2013-0269
gem "json", "~> 2.3.0"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :development, :test do
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
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner', ">= 1.0.0"
  gem "jasmine", git: "https://github.com/pivotal/jasmine-gem.git"
  gem 'sinon-rails'
  gem 'rails-controller-testing'
end
