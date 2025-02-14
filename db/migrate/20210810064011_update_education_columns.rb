class UpdateEducationColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :educations, :university, :string, null: false 
    add_column :educations, :state, :string
    add_column :educations, :city, :string
    add_column :educations, :country, :string
    remove_column :educations, :education, :string 
  end
end
