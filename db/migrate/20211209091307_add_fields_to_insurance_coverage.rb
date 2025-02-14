class AddFieldsToInsuranceCoverage < ActiveRecord::Migration[6.1]
  def change
    add_column :insurance_coverages, :amd_front_card_view_id, :string
    add_column :insurance_coverages, :amd_back_card_view_id, :string
  end
end
