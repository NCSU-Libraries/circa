require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
ENV.update YAML.load_file('config/archivesspace.yml')[Rails.env] rescue {}
ENV.update YAML.load_file('config/solr.yml')[Rails.env] rescue {}
ENV.update YAML.load_file('config/email.yml')[Rails.env] rescue {}
ENV.update YAML.load_file('config/options.yml')[Rails.env] rescue {}

module Circa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    config.action_mailer.delivery_method = :sendmail

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    if Rails.env == 'test'
      config.autoload_paths += %W(#{config.root}/spec)
      config.autoload_paths += Dir["#{config.root}/spec/**/"]
    end

    config.assets.paths << Rails.root.join("vendor","assets","bower_components")

    config.assets.logger = false

    config.active_job.queue_adapter = :resque

  end
end
