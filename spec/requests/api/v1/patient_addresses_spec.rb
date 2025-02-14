require "rails_helper"

RSpec.describe "Api::V1::PatientAddresses", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:clinician_address) { create(:clinician_address) }
  
  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  describe "PUT /api/v1/patients/:id/patient_addresses" do
    let(:patient) { create(:patient) }

    context "when patient not found" do
      params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta",
                 "state" => "Florida", "postal_code" => "30301" }
      before { token_encoded_put("/api/v1/patients/0/patient_addresses", params: params, token: @token) }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
        expect(json_response["message"]).to include("Patient not found")
      end
    end

    context "for invalid request" do
      it "returns 401 for an unauthorized request" do
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta",
                   "state" => "Florida", "postal_code" => "30301" }
        token_encoded_put("/api/v1/patients/#{patient.id}/patient_addresses", params: params, token: nil)

        expect(response).to have_http_status(401)
      end

      it "respond with error for request without address_line1" do
        params = { "address_line1" => nil, "address_line2" => "Blueflies street", "city" => "Atlanta", "state" => "Florida",
                   "postal_code" => "30301" }
        VCR.use_cassette("create_patient_intake_address_data") do
          token_encoded_put("/api/v1/patients/#{patient.id}/patient_addresses", params: params, token: @token)
        end
        expect(json_response["message"]).to eq("Error occured in saving patient address information")
        expect(json_response["error"]).to eq("Failed to save the new associated intake_address.")
      end

      it "respond with error for request without city" do
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => nil, "state" => "Florida",
                   "postal_code" => "30301" }
        VCR.use_cassette("create_patient_intake_address_data") do
          token_encoded_put("/api/v1/patients/#{patient.id}/patient_addresses", params: params, token: @token)
        end
        expect(json_response["message"]).to eq("Error occured in saving patient address information")
        expect(json_response["error"]).to eq("Failed to save the new associated intake_address.")
      end

      it "respond with error for request without state" do
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta", "state" => nil,
                   "postal_code" => "30301" }
        token_encoded_put("/api/v1/patients/#{patient.id}/patient_addresses", params: params, token: @token)

        expect(json_response["message"]).to eq("Error occured in saving patient address information")
        expect(json_response["error"]).to eq("Failed to save the new associated intake_address.")
      end
    end

    context "for valid request" do
      it "return 200 on success" do
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta",
                   "state" => "AT", "postal_code" => "30301" }
        VCR.use_cassette("create_patient_intake_address_data") do
          token_encoded_put("/api/v1/patients/#{patient.id}/patient_addresses", params: params, token: @token)
        end

        expect(json_response["message"]).to eq("Intake address successfully added to patient")
        expect(response).to have_http_status(200)
      end

      it "should add intake address to the patient" do
        current_patient = patient
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta",
                   "state" => "AT", "postal_code" => "30301" }
        VCR.use_cassette("create_patient_intake_address_data") do
          token_encoded_put("/api/v1/patients/#{current_patient.id}/patient_addresses", params: params, token: @token)
        end
        expect(current_patient.intake_address.slice(:address_line1, :address_line2, :city, :state,
                                                    :postal_code)).to eq(params)
      end

      it "should update intake address to the patient" do
        VCR.use_cassette("create_patient_intake_address_data") do
          intake_address = create(:intake_address, intake_addressable: patient)
        end
        current_patient = patient
        params = { "address_line1" => "3rd avenue", "address_line2" => "Blueflies street", "city" => "Atlanta",
                   "state" => "AT", "postal_code" => "30301" }
        VCR.use_cassette("update_patient_intake_address_data") do
          token_encoded_put("/api/v1/patients/#{current_patient.id}/patient_addresses", params: params, token: @token)
        end
        expect(current_patient.intake_address.slice(:address_line1, :address_line2, :city, :state,
                                                    :postal_code)).to eq(params)
      end
    end
  end
end
