class ImportConsentForms < ActiveRecord::Migration[6.1]
  def up
    #Rake::Task["consent_forms:import_ohio_consent_forms"].invoke
  end

  def down
    #ConsentForm.delete_all
  end
end
