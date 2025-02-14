# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "factory_bot_rails"
require "shoulda/matchers"
require "sidekiq/testing"
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)
  config.include(AmdApiHelpers, type: :request)
  config.include(AmdApiHelpers, type: :class)
  config.include(AmdApiHelpers, type: :worker)
  config.include(AmdApiHelpers, type: :model)
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

def skip_patient_amd_creation
  allow_any_instance_of(Patient).to receive(:existing_amd_patient).and_return(false)
  allow_any_instance_of(Patient).to receive(:create_amd_patient).and_return(nil)
end

def skip_intake_address_amd_creation
  allow_any_instance_of(IntakeAddress).to receive(:update_patient_address).and_return(nil)
end

def skip_insurance_coverage_amd_creation
  allow_any_instance_of(InsuranceCoverage).to receive(:create_amd_insurance_data).and_return(nil)
end

def skip_referral_amd_creation
  skip_patient_amd_creation
  referral_api = Amd::Api::ReferralApi.new(
    Amd::AmdConfiguration.new,
    authenticate_amd(102).base_url,
    authenticate_amd(102).token
  )

  allow(Amd::AmdClient).to receive(:new).and_return(OpenStruct.new(referrals: referral_api))
  allow_any_instance_of(Amd::Api::ReferralApi).to receive(:lookup_ref_source).and_return(999)
  allow_any_instance_of(Amd::Api::ReferralApi).to receive(:add_patients_referral_source).and_return(768)
end
