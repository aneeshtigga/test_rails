require "rails_helper"

# Stubs the Amd:Api:BaseApi#send_request
# returns a fake_response when its not nil
#

require "#{Rails.root}/spec/support/mocks_and_stubs/amd_api_baseapi_stub"


RSpec.describe Amd::Api::PatientApi, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let(:config) do
    Amd::AmdConfiguration.setup do |config|
      config.request_endpoint = "xmlrpc/processrequest.aspx"
    end
  end

  let!(:clinician_address) { create(:clinician_address) }
  let(:patient_api) { Amd::Api::PatientApi.new(config, authenticate_amd(102).base_url, authenticate_amd(102).token) }

  describe "#lookup_patient" do
    let(:params) do
      {
        first_name: "brenda",
        last_name: "bianchi",
        date_of_birth: "11/03/1964",
        email: "brenda.bianchi@example.com",
        gender: "female"
      }
    end

    it "returns the correct patient" do        
      patient_api.load_fake_response_from('lookup_patient_multiple_returns')

      patient = patient_api.lookup_patient(params)

      expect(patient).to have_attributes(
        id: "pat54",
        name: "BIANCHI,BRENDA",
        date_of_birth: "11/03/1964",
        email: "BRENDA.BIANCHI@EXAMPLE.COM",
        gender: "F",
        zip_code: "36605",
      )
    end

    describe "patient is not found" do
      let(:params) do
        {
          first_name: "bren",
          last_name: "bianci",
          date_of_birth: "11/03/1964",
          email: "brenda.bianchi@example.com",
          gender: "female"
        }
      end

      it "returns nil if patient isn't found" do
        patient_api.load_fake_response_from "lookup_patient_not_found"

        patient = patient_api.lookup_patient(params)

        expect(patient).to be_nil
      end
    end
  end

  describe "#add_patient" do
    let(:params) do
      {
        "@respparty" => "SELF",
        "@name" => "penguin,pororo",
        "@sex" => "M",
        "@relationship" => "1",
        "@hipaarelationship" => "18",
        "@dob" => "12/04/1989",
        "@ssn" => "",
        "@chart" => "AUTO",
        "@profile" => "3",
        "@finclass" => "",
        "@deceased" => "",
        "@title" => "MR",
        "@maritalstatus" => "2",
        "@insorder" => "",
        "@employer" => "encoratest, inc.",
        address: {
          "@zip" => "38834",
          "@city" => "CORINTH",
          "@state" => "MS",
          "@address1" => "apt b-5",
          "@address2" => "6923 n mountainside dr",
        },
        contactinfo: {
          "@homephone" => "(662) 555-1343",
          "@officephone" => "(662) 555-9238",
          "@officeext" => "213",
          "@otherphone" => "(662) 555-3823",
          "@othertype" => "C",
          "@email" => "pororo.penguin.test@example.com"
        },
        resppartylist: {
          respparty: {
            "@respparty_name" => "",
            "@accttype" => ""
          }
        }
      }
    end

    let(:patient_api) { Amd::Api::PatientApi.new(config, authenticate_amd(102).base_url, authenticate_amd(102).token) }

    it "returns the patient created" do
      patient_api.load_fake_response_from "add_patient"

      patient = patient_api.add_patient(params)

      expect(patient["@id"]).to_not be_nil
    end

    it "will set the otherphone for patient" do              
      patient_api.load_fake_response_from "add_patient"

      patient = patient_api.add_patient(params)
      
      expect(patient["contactinfo"]["@othertype"]).to eq("C") #cell
      expect(patient["contactinfo"]["@otherphone"]).to eq(params[:contactinfo]["@otherphone"])
    end

    describe "patient is not created" do
      let(:params) do
        {
          "@respparty" => "SELF",
          "@name" => "penguin,pororo1111111",
          "@sex" => "M",
          "@relationship" => "1",
          "@hipaarelationship" => "18",
          "@dob" => "12/04/1989",
          "@ssn" => "",
          "@chart" => "AUTO",
          "@profile" => "3",
          "@finclass" => "",
          "@deceased" => "",
          "@title" => "MR",
          "@maritalstatus" => "2",
          "@insorder" => "",
          "@employer" => "encoratest, inc.",
          address: {
            "@zip" => "38834",
            "@city" => "CORINTH",
            "@state" => "MS",
            "@address1" => "apt b-5",
            "@address2" => "6923 n mountainside dr",
          },
          contactinfo: {
            "@homephone" => "(662) 555-1343",
            "@officephone" => "(662) 555-9238",
            "@officeext" => "213",
            "@otherphone" => "(662) 555-3823",
            "@othertype" => "C",
            "@email" => "pororo.penguin.test@example.com"
          },
          resppartylist: {
            respparty: {
              "@respparty_name" => "",
              "@accttype" => ""
            }
          }
        }
      end


      it "returns fault key when adding a patient fails" do
        patient_api.load_fake_response_from "add_patient_failed"

        patient = patient_api.add_patient(params)

        expect(patient["Fault"]).to be_present
      end
    end
  end

  describe "#lookup_responsible_party_value" do
    let(:params) do
      {
        "@respparty" => "SELF",
        "@name" => "MICK,MOUSE",
        "@sex" => "M",
        "@relationship" => "1",
        "@hipaarelationship" => "18",
        "@dob" => "12/04/1989",
        "@ssn" => "",
        "@chart" => "AUTO",
        "@profile" => "3",
        "@finclass" => "",
        "@deceased" => "",
        "@title" => "MR",
        "@maritalstatus" => "2",
        "@insorder" => "",
        "@employer" => "encoratest, inc.",
        address: {
          "@zip" => "38834",
          "@city" => "CORINTH",
          "@state" => "MS",
          "@address1" => "apt b-5",
          "@address2" => "6923 n mountainside dr",
        },
        contactinfo: {
          "@homephone" => "(662) 555-1343",
          "@officephone" => "(662) 555-9238",
          "@officeext" => "213",
          "@otherphone" => "(662) 555-3823",
          "@othertype" => "C",
          "@email" => "pororo.penguin.test@example.com"
        },
        resppartylist: {
          respparty: {
            "@respparty_name" => "",
            "@accttype" => ""
          }
        }
      }
    end

    let(:patient_api) { Amd::Api::PatientApi.new(config, authenticate_amd(102).base_url, authenticate_amd(102).token) }

    it "responsible party is not a match because DOB" do
      patient_api.load_fake_response_from "lookup_responsible_party_value"

      responsible_party_id = patient_api.lookup_responsible_party_value(params)

      expect(responsible_party_id).to eq("SELF")
    end


    describe "responsible party is a match" do
      let(:params) do
        {
          "@respparty" => "SELF",
          "@name" => "MICK,MOUSE", ### MATCHING LAST NAME, FIRST NAME
          "@sex" => "M",
          "@relationship" => "1",
          "@hipaarelationship" => "18",
          "@dob" => "09/21/1989", ### MATCHING DOB
          "@ssn" => "",
          "@chart" => "AUTO",
          "@profile" => "3",
          "@finclass" => "",
          "@deceased" => "",
          "@title" => "MR",
          "@maritalstatus" => "2",
          "@insorder" => "",
          "@employer" => "encoratest, inc.",
          address: {
            "@zip" => "38834",
            "@city" => "CORINTH",
            "@state" => "MS",
            "@address1" => "apt b-5",
            "@address2" => "6923 n mountainside dr",
          },
          contactinfo: {
            "@homephone" => "(662) 555-1343",
            "@officephone" => "(662) 555-9238",
            "@officeext" => "213",
            "@otherphone" => "(662) 555-3823",
            "@othertype" => "C",
            "@email" => "pororo.penguin.test@example.com"
          },
          resppartylist: {
            respparty: {
              "@respparty_name" => "",
              "@accttype" => ""
            }
          }
        }
      end

      it "the responsible party is a FIRST NAME, LAST NAME, DOB are a match so it returns the respxxxx ID AND AMD RETURNS ONLY 1 OBJECT" do
        patient_api.load_fake_response_from "lookup_responsible_party_value_one"

        params["@name"] = 'MOUSE,MICK'
        params["@dob"] = '10/11/2000'
        responsible_party_id = patient_api.lookup_responsible_party_value(params)

        # BEING A MATCH, WE EXPECT THE RESPONSIBLE PARTY ID
        expect(responsible_party_id).to_not eq("SELF")
        expect(responsible_party_id).to start_with("resp")
      end

      it "the responsible party is a FIRST NAME, LAST NAME, DOB are a match so it returns the respxxxx ID" do
        patient_api.load_fake_response_from "lookup_responsible_party_value"

        params["@name"] = 'MOUSE,MICK'
        responsible_party_id = patient_api.lookup_responsible_party_value(params)

        # BEING A MATCH, WE EXPECT THE RESPONSIBLE PARTY ID
        expect(responsible_party_id).to_not eq("SELF")
        expect(responsible_party_id).to start_with("resp")
      end

      it "the responsible party is a FIRST NAME, LAST NAME, DOB are not a match (Different name) so it returns SELF as respid" do
        patient_api.load_fake_response_from "lookup_responsible_party_value"

        responsible_party_id = patient_api.lookup_responsible_party_value(params)

        # NOT BEING A MATCH, WE EXPECT "SELF"
        expect(responsible_party_id).to eq("SELF")
      end
    end
  end

  describe "#update_patient" do
    let(:patient_api) { Amd::Api::PatientApi.new(config, authenticate_amd(101).base_url, authenticate_amd(101).token) }

    let(:params) do
      { "@id" => "5983948",
        "@name" => "updated,name",
        address: { "@address1" => "Updated Address 1" },
        contactinfo: { "@email" => "updatedemail@email.com" } }
    end

    context "when the update is correct" do
      it "returns the patient updated attributes" do
        patient_api.load_fake_response_from "update_patient"

        patient = patient_api.update_patient(params)

        expect(patient).to include(
          "@id" => "pat5983948",
          "@name" => "UPDATED,NAME"
        )

        expect(patient["address"]).to include(
          "@address1" => "UPDATED ADDRESS 1"
        )

        expect(patient["contactinfo"]).to include(
          "@email" => "UPDATEDEMAIL@EMAIL.COM"
        )
      end
    end

    context "when the patient is not found" do
      let(:params) do
        { "@id" => "",
          "@name" => "updated name",
          "@employer" => "employer updated"}
      end

      it "Fault key is present" do
        patient_api.load_fake_response_from "update_patient_fails"

        patient = patient_api.update_patient(params)

        expect(patient["Fault"]).to_not be_empty
      end
    end
  end

  describe "#get_demographics" do 
    it "returns the patients demographics info from AMD by patient ID" do       
      patient_api.load_fake_response_from "amd/get_patient_demographics_success"

      expect(patient_api.get_demographics(5983942).profile_data).to eq({:id=>5983942, :name=>"GODINEZ ROGELIO", :date_of_birth=>"12/04/1989", :location => "BLUEFLIES STREET,3RD AVENUE,ATLANTA,AT,30301" , :gender=>"male"})
    end

    it "returns error message when no patient availabile on AMD for requested ID" do   
      patient_api.load_fake_response_from "amd/get_patient_demographics_failure"

      expect(patient_api.get_demographics("-123")["Fault"]).to_not be_empty
    end
  end
end
