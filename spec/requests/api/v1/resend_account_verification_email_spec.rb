require "rails_helper"
RSpec.describe "Api::V1::ResendAccountVerificationEmail", type: :request do
  describe "PUT /api/v1/account_holders/update_email" do
    let(:account_holder) { create(:account_holder) }
    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "updates account holder email with status 200" do
      token_encoded_patch("/api/v1/resend_account_verification_email/#{account_holder.id}", params: {'email': "test@gmail.com"}, token: @token)

      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("polaris_test_default").at_most(:twice)
      expect(response).to have_http_status(:ok)
      expect(AccountHolder.all.size).to eq(1)
      expect(AccountHolder.first).to have_attributes('email': "test@gmail.com")
    end

    it "updates account holder email with status 200" do
      token_encoded_patch("/api/v1/resend_account_verification_email/#{account_holder.id}", params: {'email': "test@gmail.com", 'booked_by': "admin"}, token: @token)

      expect(response).to have_http_status(:ok)
      expect(AccountHolder.all.size).to eq(1)
      expect(AccountHolder.first).to have_attributes('email': "test@gmail.com")
    end

    it "throws error when any params that is required is not passed like email" do
      token_encoded_patch("/api/v1/resend_account_verification_email/#{account_holder.id}", params: {'email': nil}, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("Validation failed: Email can't be blank")
    end
  end
end
