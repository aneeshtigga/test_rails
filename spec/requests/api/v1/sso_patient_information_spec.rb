require "rails_helper"

RSpec.describe "Sso::Patient::Information", type: :request do

  let!(:clinician_address) { create(:clinician_address) }

  describe "POST /api/v1/existing_patient_information" do
    describe "with a valid session available" do
      it "returns success" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456"} }
        
        VCR.use_cassette('amd/get_patient_demographics') do
          get("/api/v1/existing_patient_information")
        end
        
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /api/v1/existing_patient_information" do
    describe "with a session not present" do
      it "returns unauthorized" do
         
        get("/api/v1/existing_patient_information")
  
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
