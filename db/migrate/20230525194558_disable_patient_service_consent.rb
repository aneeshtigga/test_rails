class DisablePatientServiceConsent < ActiveRecord::Migration[6.1]
  def change
    # ConsentForm.unscoped.where(name: "Patient Services Agreement").update_all(active: false)
  end
end
