class AddColumnToClinician < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :min_accepted_age, :integer, default: 0
    add_column :clinicians, :max_accepted_age, :integer, default: 200
  end
end
