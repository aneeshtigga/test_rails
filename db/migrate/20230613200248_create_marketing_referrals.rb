class CreateMarketingReferrals < ActiveRecord::Migration[6.1]
  def change
    create_table :marketing_referrals do |t|
      t.string :display_marketing_referral,  comment: "String being sent by the Front-end"
      t.string :amd_marketing_referral, comment: "String being sent to AMD"

      t.timestamps
    end
  end
end
