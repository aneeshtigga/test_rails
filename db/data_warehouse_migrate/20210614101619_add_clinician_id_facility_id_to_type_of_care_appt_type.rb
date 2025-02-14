class AddClinicianIdFacilityIdToTypeOfCareApptType < ActiveRecord::Migration[6.1]
  def change
    add_column :type_of_care_appt_type, :facility_id, :bigint
    add_column :type_of_care_appt_type, :clinician_id, :bigint
  end
end
