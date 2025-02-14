class AddSupervisoryFieldsToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column :vw_clinician_mart, :supervised_clinician, :boolean
    add_column :vw_clinician_mart, :supervisory_disclosure, :string
    add_column :vw_clinician_mart, :supervisory_type, :string
    add_column :vw_clinician_mart, :supervising_clinician, :text
    add_column :vw_clinician_mart, :display_supervised_msg, :boolean
  end
end
