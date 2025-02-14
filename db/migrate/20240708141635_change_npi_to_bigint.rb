class ChangeNpiToBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :clinicians, :npi, :string, null: false
  end
end
