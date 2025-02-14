class AddActiveToMarketingReferrals < ActiveRecord::Migration[6.1]
  def change
    add_column :marketing_referrals, :active, :boolean, :default => true, comment: "Active if it should be shown"
    add_column :marketing_referrals, :order, :integer, comment: "Display order for marketing referrals"

    # This NO NULL constraint was causing issues when updating patient_disorders.
    change_column_null :patient_disorders, :concern_id, true
  end
end
