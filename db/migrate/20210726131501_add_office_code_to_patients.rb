class AddOfficeCodeToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :office_code, :integer
  end
end
