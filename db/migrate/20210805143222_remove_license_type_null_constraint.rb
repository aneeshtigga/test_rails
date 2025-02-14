class RemoveLicenseTypeNullConstraint < ActiveRecord::Migration[6.1]
  def change
    change_column :clinicians, :license_type, :string, null: true
  end
end
