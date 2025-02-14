class RemoveCliniciansNotNullConstraints < ActiveRecord::Migration[6.1]
  def change
    change_column_null :clinicians, :accepting_new_patients, true, false
    change_column_null :clinicians, :in_office, true, false
    change_column_null :clinicians, :video_visit, true, false
    change_column_null :clinicians, :manages_medication, true, false

    change_column_default :clinicians, :accepting_new_patients, from: true, to: false
    change_column_default :clinicians, :in_office, from: true, to: false
    change_column_default :clinicians, :video_visit, from: true, to: false
  end
end
