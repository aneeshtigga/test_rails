class ActiverecordSsoSessionClearWorker
  include Sidekiq::Worker
  sidekiq_options queue: :active_record_sso_session_clear_worker_queue, retry: false

  def perform
    begin
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      audit_data = {
        active_sessions_count: ActiveRecord::SessionStore::Session.count
      }
      ActiveRecord::SessionStore::Session.where('created_at <= ?', (Time.now - 5.minutes)).destroy_all
      status = :completed
    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
        job_name: "ActiverecordSsoSessionClearWorker", 
        params: {},
        audit_data: audit_data,
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status,
      })
    end
  end
end
