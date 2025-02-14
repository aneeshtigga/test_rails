class AddRemoveColumnsToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    rename_column :clinician_mart, :provider_id, :clinician_id
    rename_column :clinician_mart, :firstname, :first_name
    rename_column :clinician_mart, :lastname, :last_name
    rename_column :clinician_mart, :zipcode, :zip_code
    rename_column :clinician_mart, :areacode, :area_code
    rename_column :clinician_mart, :countrycode, :country_code

    add_column :clinician_mart, :middle_name, :string
    add_column :clinician_mart, :photo, :string
    add_column :clinician_mart, :facility_name, :string
    add_column :clinician_mart, :facility_id, :integer
    add_column :clinician_mart, :apt_suite, :string
    add_column :clinician_mart, :is_active, :boolean

    rename_column :clinician_mart, :created_at, :create_timestamp
    rename_column :clinician_mart, :updated_at, :change_timestamp
    rename_table :clinician_mart, :vw_clinician_mart
  end
end
