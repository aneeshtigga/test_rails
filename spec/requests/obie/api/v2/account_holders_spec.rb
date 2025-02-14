require "rails_helper"

RSpec.describe "AccountHolders", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "PUT send confirmation email" do
    let!(:state) { create(:state, name: "FL", full_name: "Florida") }
    let!(:patient_appointment) { create(:patient_appointment) }
    let!(:account_holder) { patient_appointment.patient.account_holder }

    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "returns an error object when id does not exist" do
      params = { email_address: account_holder.email }
      token_encoded_put("/obie/api/v2/account_holders/999999/send_confirmation_email", params: params, token: @token)

      expect(JSON.parse(response.body).keys.size).to eq(2)
      expect(JSON.parse(response.body).keys).to eq(%w[message error])
      expect(JSON.parse(response.body)["message"]).to eq("Error sending confirmation email")
    end

    context "with a valid id" do
      before do
        Sidekiq::Testing.inline! do
          params = { email_address: "confirmation@email.com" }
          token_encoded_put(
            "/obie/api/v2/account_holders/#{account_holder.id}/send_confirmation_email",
            params: params, token: @token
          )
        end
      end
  
      it "responds with email_sent as true" do
        expect(JSON.parse(response.body)["email_sent"]).to be_truthy
      end
      
      it "responds with success message" do
        expect(JSON.parse(response.body)["message"]).to eq("Confirmation email sent")
      end
      
      it "sends an email" do
        account_holder.reload
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq([account_holder.confirmation_email])
        expect(email.subject).to include("LifeStance Appointment Confirmation")
      end

      it "does not update the account holder's email" do
        account_holder.reload
        expect(account_holder.email).not_to eq("confirmation@email.com")
      end
    end
  end

end