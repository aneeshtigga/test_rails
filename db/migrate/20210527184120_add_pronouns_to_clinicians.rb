class AddPronounsToClinicians < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :pronouns, :string
  end
end
