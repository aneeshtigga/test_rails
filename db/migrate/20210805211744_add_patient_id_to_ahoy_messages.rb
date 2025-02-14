class AddPatientIdToAhoyMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :ahoy_messages, :patient_id, :integer
  end
end
