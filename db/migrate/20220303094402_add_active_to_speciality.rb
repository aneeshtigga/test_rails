class AddActiveToSpeciality < ActiveRecord::Migration[6.1]
  def change
    add_column :specialities, :active, :boolean, default: true
  end
end
