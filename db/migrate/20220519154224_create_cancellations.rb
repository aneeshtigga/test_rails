class CreateCancellations < ActiveRecord::Migration[6.1]
  def change
    create_table :cancellations do |t|
      
      t.string :cancelled_by

      t.references :cancellation_reason, foreign_key: true
      t.references :patient_appointment, foreign_key: true

      t.timestamps
    end
  end
end
