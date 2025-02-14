class AddMiddleNamePhotoToClinicians < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :middle_name, :string
    add_column :clinicians, :photo, :string
  end
end
