source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

# This should be the first gem listed, so that appmap is loaded first
gem 'appmap', group: %i[test development qa]

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '6.1.7.3'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

gem 'activerecord-cte' # Add Common Table Expressions to AR

# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem 'activeadmin'
gem 'devise'
gem 'omniauth'
gem 'omniauth-saml'
gem 'cancancan'
gem 'httparty'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem 'icalendar'
gem 'image_optim'
gem 'image_optim_pack'
gem "image_processing"
gem "mini_magick"
gem 'rest-client', '~> 2.1'

group :development, :test, :dev, :qa do
  # Use sqlite3 as the database for Active Record
  gem 'rspec-rails', '~> 5.0', '>= 5.0.1'
  gem 'sqlite3', '~> 1.4'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'pry-byebug', '~> 3.9'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'awesome_print'
  gem 'timecop'
  gem 'pact'
end

group :test do
  gem 'database_cleaner'
  gem 'json-schema'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.3'
  gem 'overcommit'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rails-erd'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'jwt'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# Adapter to establish connection with redshift
gem 'active_model_serializers', '~> 0.10.0'
gem 'activerecord6-redshift-adapter'
gem 'activerecord-session_store'
gem 'ahoy_email'
gem "aws-sdk-s3", require: false
gem "aws-sdk-secretsmanager"
gem "bugsnag", "~> 6.21"
gem 'composite_primary_keys', '=13.0.0'
gem 'dagwood'
gem 'hiredis'
gem 'json-jwt'
gem 'pagy', '~> 4.11.0'
gem 'premailer-rails'
gem 'rack-cors'
gem 'redis-namespace'
gem 'sidekiq', '< 6'
gem 'sidekiq-cron'
gem 'slack-incoming-webhooks'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'geokit'
gem 'geokit-rails'
