class CreatePatientConsents < ActiveRecord::Migration[6.1]
  def change
    create_table :patient_consents do |t|
      t.integer :consent_form_id
      t.integer :account_holder_id
      t.integer :patient_id
      t.string :pdf_url, null: false
      t.string :signature_url, null: false

      t.timestamps
    end
  end
end
