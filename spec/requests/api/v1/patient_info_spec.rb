require "rails_helper"

RSpec.describe "Patient Info", type: :request do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "GET /api/v1/patient_info" do

    let(:session_params) do
       [{"date_of_birth"=>"01/15/1986",
         "gender"=>"male",
          "id"=>5984106,
           "location"=>"TEST STREET,MONTGOMERY,AL,36111",
            "name"=>"AMI SHAH"}]
       end

    describe "with a valid token" do
      it "creates a session" do
        token = create(:sso_token, token: "12345", data: { selected_patient_id: "100" })
        get "/api/v1/patient_info", params: { token: "12345" }

        expect(json_response).to eq("patient_info" => {
          "selected_patient_id" => "100",
          "license_key" => nil,
          "responsible_party_id" => nil,
          "authorized_patient_ids" => nil,
          "authorized_patients_list" => []
        })

        get "/api/v1/patient_info"

        expect(json_response).to eq("patient_info" => {
          "selected_patient_id" => "100",
          "license_key" => nil,
          "responsible_party_id" => nil,
          "authorized_patient_ids" => nil,
          "authorized_patients_list" => []
        })
      end

      it "creates session and returns authorised patients data" do
        create(:clinician_address)
        token = create(:sso_token, token: "12345", data: { selected_patient_id: "67", license_key: "995456", authorized_patient_ids: "5984106", authorized_patients_list: session_params })
        VCR.use_cassette("amd/get_patient_demographics") do 
          get "/api/v1/patient_info", params: { token: "12345" }

          expect(json_response).to eq("patient_info" => {
            "selected_patient_id"=>"67",
             "license_key"=>"995456",
             "responsible_party_id"=>nil,
             "authorized_patient_ids"=>"5984106",
             "authorized_patients_list"=>[{"date_of_birth"=>"01/15/1986", "gender"=>"male", "id"=>5984106, "location"=>"", "name"=>"AMI SHAH"}]
          })
        end
      end

      it "it invalids a previously used token" do
        token = create(:sso_token, token: "12345", data: { selected_patient_id: "100" })
        token.update!(expire_at: Time.now)

        get "/api/v1/patient_info", params: { token: "12345" }

        expect(json_response).to eq("message" => "Session expired")
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized" do
        get "/api/v1/patient_info"

        expect(json_response).to eq("message" => "Session expired")
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
