require "rails_helper"

RSpec.describe Amd::Api::AppointmentApi, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:authenticate_amd) do
    VCR.use_cassette("amd/authenticate_amd") do
      Amd::AmdClient.new(office_code: 995456).authenticate 
    end
  end

  let(:base_url) { "https://#{authenticate_amd[0].scan(/api-\d\d\d/).last}.advancedmd.com/API/scheduler/Appointments" }
  
  let(:token) { authenticate_amd[1] }
      
  let(:appointment_api) { Amd::Api::AppointmentApi.new(config, base_url, token) }

  describe "#add_appointment" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = nil
      end
    end

    let(:params) do
      {
        patientid: 5_983_949,
        columnid: 17,
        startdatetime: "2021-12-29T08:00:00.0Z",
        duration: 30,
        color: "string",
        profileid: 9,
        episodeid: 1,
        type: [
          {
            id: 1
          }
        ],
        comments: "Sample Appointment note"
      }
    end

    describe "Appointment is created" do
      it "returns the appointment object created" do
        result = VCR.use_cassette("amd/create_appointment") do
                  appointment_api.add_appointment(params)
                end

        expect(result).to_not be_empty
        expect(result["id"]).to eq(result["id"])
      end

      it "creates appointment with appointment note" do
        VCR.use_cassette("amd/create_appointment") do
          result = appointment_api.add_appointment(params)

          expect(result).to_not be_empty
          expect(result["comments"]).to eq(params[:comments])
        end
      end
    end

    describe "Appointment is not created" do
      it "returns an object with title and detail error message" do
        VCR.use_cassette("amd/create_appointment_failed") do
          result = appointment_api.add_appointment(params)

          expect(result).to eq({})
        end
      end
    end
  end

  describe "#lookup_appointment" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    describe "Appointment exists" do
      let(:params) do
        {
          id: "9543326",
          client_date_time: "",
          get_recur_exception: true,
          include_detail: true
        }
      end

      it "returns the appointment found by id" do
        VCR.use_cassette("amd/lookup_appointment") do
          result = appointment_api.lookup_appointment(params)

          expect(result["id"]).to eq(9543326)
        end
      end
    end

    describe "Appointment does not exist" do
      let(:params) do
        {
          id: "0000",
          client_date_time: "",
          get_recur_exception: true,
          include_detail: true
        }
      end

      it "returns empty hash" do
        VCR.use_cassette("amd/lookup_appointment_not_found") do
          result = appointment_api.lookup_appointment(params)

          expect(result["id"]).to be_nil
        end
      end
    end
  end

  describe "#cancel_appointment" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = nil
      end
    end

    let(:params) do
      { id: 9543446 }
    end

    describe "Appointment is cancelled" do
      it "returns the updated appointment object" do
        VCR.use_cassette("amd/cancel_appointment") do
          response = appointment_api.cancel_appointment(params.as_json)

          expect(response).to_not be_empty
          expect(response["id"]).to eq(9543446)
          expect(response["status"]).to eq(10)
        end
      end
    end
  end
end