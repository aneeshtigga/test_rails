class AddCboFieldToTypeOfCareApptTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :type_of_care_appt_type, :cbo, :integer
  end
end
