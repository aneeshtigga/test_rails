class CreateAuditJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :audit_jobs do |t|
      t.string :job_name
      t.json :params, default: {}
      t.json :audit_data, default: {}
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status

      t.timestamps
    end
  end
end
