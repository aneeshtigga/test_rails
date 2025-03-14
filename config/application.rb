require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require_relative "initializers/multipart_buffer_setter"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Polaris
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # Don't generate system test files.
    config.autoload_paths += Dir["#{config.root}/app/lib/**/"]
    config.autoload_paths += %W[#{config.root}/lib]
    config.generators.system_tests = nil
    config.middleware.delete Rack::Sendfile
    config.middleware.insert_before Rack::Runtime, MultipartBufferSetter
    config.active_job.queue_adapter = :sidekiq
    # config.active_job.queue_name_prefix = "polaris_#{Rails.env}"
    # config.active_job.queue_name_delimiter = "_"
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    unless Rails.env.production?
      config.action_mailer.smtp_settings = {
        user_name: Rails.application.credentials.smtp_username,
        password: Rails.application.credentials.smtp_password,
        address: Rails.application.credentials.smtp_address,
        domain: Rails.application.credentials.smtp_domain,
        port: Rails.application.credentials.smtp_port,
        authentication: Rails.application.credentials.smtp_authentication
      }
    end

    # disable CSRF protection
    config.action_controller.allow_forgery_protection = false
  end
end