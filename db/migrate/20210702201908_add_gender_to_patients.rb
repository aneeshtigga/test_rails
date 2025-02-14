class AddGenderToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :gender, :string, null: false
  end
end
