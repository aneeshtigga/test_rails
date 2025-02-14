require "rails_helper"

RSpec.describe AccountHoldersController, type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "PUT send confirmation email" do
    let!(:state) { create(:state, name: "FL", full_name: "Florida") }
    let!(:patient_appointment) { create(:patient_appointment) }
    let!(:account_holder) { patient_appointment.patient.account_holder }

    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "returns an error when account holder ID does not exist" do
      params = { email_address: account_holder.email }
      token_encoded_put("/obie/api/v2/account_holders/999999/send_confirmation_email", params: params, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Account holder does not exist")
    end

    it "responds with success" do

      params = { email_address: account_holder.email }
      token_encoded_put("/obie/api/v2/account_holders/#{account_holder.id}/send_confirmation_email", params: params, token: @token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Confirmation email sent")
    end
  end

end
