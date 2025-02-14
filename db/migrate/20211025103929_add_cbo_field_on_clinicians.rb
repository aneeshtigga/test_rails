class AddCboFieldOnClinicians < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :cbo, :integer
  end
end
