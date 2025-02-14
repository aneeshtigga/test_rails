class AddAmdReferenceColumnsToEmergencyContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :emergency_contacts, :amd_contact_id, :bigint
    add_column :emergency_contacts, :amd_relationship_to_patient_id, :bigint
    add_column :emergency_contacts, :amd_phone_id, :bigint
    add_column :emergency_contacts, :amd_instance_id, :bigint
  end
end
