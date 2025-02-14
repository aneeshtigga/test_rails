class AddIndexOnClinicianAcceptedAge < ActiveRecord::Migration[6.1]
  def change
    add_index :clinician_accepted_ages, :clinician_id
    add_index :clinician_accepted_ages, :max_accepted_age
    add_index :clinician_accepted_ages, :min_accepted_age
  end
end
