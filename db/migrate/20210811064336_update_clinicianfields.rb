class UpdateClinicianfields < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :license_key, :integer
    add_index :clinicians, [:provider_id,:license_key], name: "index_clinicians_on_provider_id_and_license_key"
    remove_index :clinicians, [:provider_id], name: "index_clinicians_on_provider_id"
  end
end