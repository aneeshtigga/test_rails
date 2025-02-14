class DailyPostgresImportOrchestratorWorker
    include Sidekiq::Worker
    sidekiq_options queue: :daily_postgres_import_orchestrator_worker_queue, retry: 1
  
    def perform(*_args)
      
        start_time = DateTime.now.utc
        audit_data = {}
        status = :failed

        ImportClinicianMartWorker.perform_async
        ImportClinicianLocationsWorker.perform_async
        ImportClinicianEducationsWorker.perform_async
        ImportCarrierCategoriesWorker.perform_async
        
        audit_data = 'Jobs Launched'
        
        status = :completed
  
    rescue StandardError => e
        ErrorLogger.report(e.message)
        Bugsnag.notify(e)
        status = :failed
        raise e
    ensure
        AuditJob.create!({
                           job_name: "DailyPostgresImportOrchestratorWorker",
                           params: {},
                           audit_data: audit_data,
                           start_time: start_time,
                           end_time: DateTime.now.utc,
                           status: status,
                         })
      
    end
end
  