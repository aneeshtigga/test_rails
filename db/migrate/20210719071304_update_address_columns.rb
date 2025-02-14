class UpdateAddressColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :addresses, :addressable_id, :clinician_id
    remove_column :addresses, :addressable_type
  end
end
