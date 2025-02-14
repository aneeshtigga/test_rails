class RemoveColumnFromClinicianTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :clinicians, :min_accepted_age
    remove_column :clinicians, :max_accepted_age
  end
end
