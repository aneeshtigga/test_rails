class AddMentalHealthPhoneNumberToInsuranceCoverages < ActiveRecord::Migration[6.1]
  def change
    add_column :insurance_coverages, :mental_health_phone_number, :string
    change_column_null :insurance_coverages, :group_id, true, false
  end
end
