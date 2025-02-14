require "sidekiq/api"

class MonitoringSidekiqWorker
  include Sidekiq::Worker

  # NOTE: Removed patients_custom_data_worker_queue and insurance_worker_queue to reduce noise on the alert channel
  # Will re-introduce when a new monitoring strategy is found.
  Queues = %w[active_record_sso_session_clear_queue
              api_log_worker_queue
              associate_facilities_to_insurance_worker_queue
              clinician_address_coordinate_worker_queue
              clinician_data_worker_queue
              clinician_inactive_worker_queue
              clinician_location_data_worker_queue
              clinician_location_updater_worker_queue
              clinician_remover_worker_queue #is it used?
              clinician_sync_worker_queue
              clinician_updater_worker_queue
              create_educations_worker_queue
              create_type_of_cares_worker_queue
              import_carrier_categories_worker_queue
              import_clinician_educations_worker_queue
              import_clinician_locations_worker_queue
              import_clinician_mart_worker_queue
              import_special_cases_worker_queue
              import_type_of_care_worker_queue
              patient_appointment_confirmation_mailer_worker_queue
              patient_appointment_hold_mailer_worker_queue
              patient_referral_source_worker_queue           
              save_insurance_card_worker_queue
              state_postal_code_worker_queue
              state_worker_queue
              update_clinician_special_case_worker_queue
              upload_insurance_card_worker_queue
              upload_insurance_worker_queue
              zip_code_worker_queue].freeze

  sidekiq_options queue: :monitoring_sidekiq_worker_queue, retry: false

  def perform
    time = 5.minutes.ago
    ds = Sidekiq::DeadSet.new
    Queues.each do |queue|
      jobs = []
      jobs = ds.select { |job| job.queue == queue && Time.zone.at(job.item["failed_at"]) >= time }
      next if jobs.blank?

      class_name = jobs.first.item["class"]
      slack = Slack::Incoming::Webhooks.new(Rails.application.credentials.slack_webhook_url)
      attachments = [{
        title: "#{class_name} has failed #{jobs.size} jobs on #{Rails.env}",
        color: "#fb2489"
      }]
      slack.post "", attachments: attachments
    end
  end
end
