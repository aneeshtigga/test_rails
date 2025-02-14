class CreateTypeOfCareApptType < ActiveRecord::Migration[6.1]
  def change
    create_table :type_of_care_appt_type do |t|
      t.integer :amd_license_key
      t.integer :amd_appt_type_uid
      t.boolean :in_person_visit
      t.boolean :virtual_or_video_visit
      t.string :amd_appointment_type
      t.string :type_of_care
      t.string :age_group

      t.timestamps
    end
  end
end
