class AddLoadDateToVwClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column(:vw_clinician_mart, :load_date, :datetime) if Rails.env.development? || Rails.env.test?
  end
end
