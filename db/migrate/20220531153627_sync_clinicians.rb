class SyncClinicians < ActiveRecord::Migration[6.1]
  def up
    ClinicianSyncWorker.set(wait: 8.minutes).perform_async
  end
  def down
  end
end
