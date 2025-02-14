class AddPhoneNumberToMarketingReferrals < ActiveRecord::Migration[6.1]
  def change
    add_column :marketing_referrals, :phone_number, :string, comment: "Marketing Referral phone number"
  end
end
