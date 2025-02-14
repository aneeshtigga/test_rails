class AddDeletedAtToClinicians < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :deleted_at, :datetime
  end
end
