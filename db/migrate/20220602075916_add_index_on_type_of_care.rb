class AddIndexOnTypeOfCare < ActiveRecord::Migration[6.1]
  def change
    add_index :type_of_cares, :amd_license_key
    add_index :type_of_cares, :facility_id
    add_index :type_of_cares, :type_of_care
  end
end
