class AddClinicianIntoTypeOfCares < ActiveRecord::Migration[6.1]
  def change
    add_reference :type_of_cares, :clinician, foreign_key: true, null: false
  end
end
