class AddMarketingRefferalIdToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :marketing_referral_id, :integer
  end
end
