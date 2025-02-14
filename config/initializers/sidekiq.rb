require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.set :session_secret, Rails.application.credentials.secret_key_base

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
                                              Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_username.to_s)) &
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
                                                Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_password.to_s))
end

config = YAML.load_file("config/redis.yml")[Rails.env]

if Rails.application.credentials.redis_host.present?
  config[:services][:sidekiq][:host] = Rails.application.credentials.redis_host
end

redis_conf = config.merge(config[:services][:sidekiq] || {})
redis_conn = proc { Redis::Namespace.new(redis_conf[:namespace], redis: Redis.new(redis_conf)) }

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)

  if Rails.application.credentials.redis_host.present?
    config.redis = { url: "redis://#{Rails.application.credentials.redis_host}:#{Rails.application.credentials.redis_port}/0" }
  end
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)

  if Rails.application.credentials.redis_host.present?
    config.redis = { url: "redis://#{Rails.application.credentials.redis_host}:#{Rails.application.credentials.redis_port}/0" }
  end
end

schedule_file = "#{Rails.root}/config/schedule.yml"

if File.exist?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file) if YAML.load_file(schedule_file)
else
  Sidekiq::Cron::Job.destroy_all!
end
