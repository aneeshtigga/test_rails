class AddIntakeStatusAndSearchFiltersToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :applied_filters, :json
    add_column :patients, :credit_card_on_file_collected, :boolean, default: false 
    add_column :patients, :intake_status, :integer
  end
end

