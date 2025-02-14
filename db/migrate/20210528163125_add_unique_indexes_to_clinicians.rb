class AddUniqueIndexesToClinicians < ActiveRecord::Migration[6.1]
  def change
    add_index :clinicians, :provider_id, unique: true
    add_index :clinicians, :npi, unique: true
  end
end
