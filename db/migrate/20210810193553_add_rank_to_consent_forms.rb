class AddRankToConsentForms < ActiveRecord::Migration[6.1]
  def change
    add_column :consent_forms, :rank, :integer

    #Rake::Task["consent_forms:update_consent_forms"].invoke
  end
end
