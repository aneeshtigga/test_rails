class SupportInfoSerializer < ActiveModel::Serializer
  attributes :id, :cbo, :license_key, :location, :intake_call_in_number, :support_hours,
    :established_patients_call_in_number, :follow_up_url, :created_at, :updated_at, :state,
    :heartland_api_key, :marketing_referral

  def heartland_api_key
    return "" unless LicenseKeyRule.get_is_credit_card_enabled_on_file(object&.license_key)

    client = Amd::AmdClient.new(office_code: object&.license_key)
    client.transactions.merchant_account(::Amd::Api::TransactionsApi::MERCHANT_ACCOUNT_NAME)&.dig("publicApiKey")
  end

  def marketing_referral
    @instance_options[:marketing_referral]&.phone_number
  end
end
