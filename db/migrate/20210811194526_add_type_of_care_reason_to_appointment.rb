class AddTypeOfCareReasonToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :type_of_care, :string
    add_column :appointments, :reason, :string
  end
end
