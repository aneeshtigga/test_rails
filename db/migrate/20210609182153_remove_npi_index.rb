class RemoveNpiIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :clinicians, :npi, name: "index_clinicians_on_npi"
  end

end
