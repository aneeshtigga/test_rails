class AddEmailToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :email, :string
  end
end
