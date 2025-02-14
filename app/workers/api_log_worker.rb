class ApiLogWorker
  include Sidekiq::Worker
  sidekiq_options queue: :api_log_worker_queue, retry: false

  def perform(params)
    ApiRequestResponse.create(params)
  end
end
