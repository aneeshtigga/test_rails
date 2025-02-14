class AddSupervisoryFieldsToFacilityAcceptedInsurances < ActiveRecord::Migration[6.1]
  def change
    add_column :facility_accepted_insurances, :supervisors_name, :string, comment: "Supervisor's name"
    add_column :facility_accepted_insurances, :license_number, :string ,comment: "License number alphanumeric"
  end
end
