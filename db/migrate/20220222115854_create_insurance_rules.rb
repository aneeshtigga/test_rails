class CreateInsuranceRules < ActiveRecord::Migration[6.1]
  def change
    create_table :insurance_rules do |t|
      t.boolean :skip_option_flag, default: true

      t.timestamps
    end
  end
end
