class CreateTypeOfCares < ActiveRecord::Migration[6.1]
  def change
    create_table :type_of_cares do |t|
      t.integer :amd_license_key, null: false
      t.integer :amd_appt_type_uid, null: false
      t.boolean :in_person_visit, default: false
      t.boolean :virtual_or_video_visit, default: false
      t.string :amd_appointment_type
      t.string :type_of_care, null: false
      t.string :age_group

      t.timestamps
    end
  end
end
