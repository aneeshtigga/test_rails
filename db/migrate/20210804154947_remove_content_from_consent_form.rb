class RemoveContentFromConsentForm < ActiveRecord::Migration[6.1]
  def change
    remove_column :patient_consents, :signature_url, :string
    remove_column :patient_consents, :pdf_url, :string
    remove_column :consent_forms, :content, :text
  end
end
