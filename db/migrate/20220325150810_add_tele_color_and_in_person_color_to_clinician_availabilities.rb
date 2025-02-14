class AddTeleColorAndInPersonColorToClinicianAvailabilities < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_availability, :tele_color, :string unless ActiveRecord::Base.connection.column_exists?(:clinician_availability, :tele_color)
    add_column :clinician_availability, :in_person_color, :string unless ActiveRecord::Base.connection.column_exists?(:clinician_availability, :in_person_color)
  end
end
