require "rails_helper"

ENV["PACT_DO_NOT_TRACK"] = "true"
PACTS_PATH = Rails.root.join("spec", "pacts")

# load all providers
Dir.glob('spec/contracts/providers/**/*.rb').each do |file|
  require Rails.root.join(file)
end

# This is a proxy app to inject the JWT Authorization token into the request
class ProxyApp
  def initialize(app)
    @app = app
  end

  def call(env)
    token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
    @app.call(env)
  end
end
