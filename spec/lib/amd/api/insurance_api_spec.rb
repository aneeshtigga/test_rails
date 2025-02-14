require "rails_helper"

RSpec.describe Amd::Api::InsuranceApi, type: :class do
	describe "#add_insurance" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    let(:base_url) { "https://provapi.advancedmd.com/processrequest/api-101/LIFESTANCE" }
    let(:token) { "995456DpRpI4OYHWz966YDobYwBUbdxqhW9Cw1IQAFYyynzV4ygQseC5eoqYwW7EZTb+8nP3p5B6Z8LPkiLapSbE+Q+Iw8XXv9HfVnbXKsd/u67I2axmjHkPlF3ZT6GTocht3+AeP2UM9hM2tg50rWofrbTnAYy+IgvzpiNbhxGXPgQ5WiSF46NFgDHdCY/Q5k6xb3JAhqCUnBQV+h6hRX1BRsKg==" }
    let(:insurance) { Amd::Api::InsuranceApi.new(config, base_url, token) }

    describe "returns insurance party created" do

      let(:params) do
        {
          patient_id: "pat61722",
          insurance_plan: {
            id: "",
            begindate: "07/13/2021",
            enddate: "07/20/2021",
            carrier: "car7562",
            subscriber: "resp6849546",
            hipaarelationship: "18",
            relationship: "1",
            grpname: "",
            grpnum: "",
            copay: "0.0",
            copaytype: "$",
            coverage: "3",
            payerid: "",
            mspcode: "",
            eligibilityid: "",
            eligibilitystatusid: "",
            eligibilitychangedat: "",
            eligibilitycreatedat: "",
            eligibilityresponsedate: "",
            finclasscode: "",
            deductible: "0.00",
            deductiblemet: "0.00",
            yearendmonth: "1",
            lifetime: "0.00",
            self_closing: "true"
          }
        }
      end
      it "returns the insurance party method success" do
        VCR.use_cassette("amd/add_insurance_success") do
          insurance_detail = insurance.add_insurance(params)

          expect(insurance_detail["@id"]).to_not be_nil
          expect(insurance_detail["@insnotefid"]).to_not be_nil
        end
      end
    end

    describe "add insurance party is not created with wrong subscriber" do
      let(:params) do
        {
          patient_id: "pat61722",
          insurance_plan: {
            id: "",
            begindate: "07/13/2021",
            enddate: "07/20/2021",
            carrier: "car7562",
            subscriber: "resp684954",
            hipaarelationship: "18",
            relationship: "1",
            grpname: "",
            grpnum: "",
            copay: "0.0",
            copaytype: "$",
            coverage: "3",
            payerid: "",
            mspcode: "",
            eligibilityid: "",
            eligibilitystatusid: "",
            eligibilitychangedat: "",
            eligibilitycreatedat: "",
            eligibilityresponsedate: "",
            finclasscode: "",
            deductible: "0.00",
            deductiblemet: "0.00",
            yearendmonth: "1",
            lifetime: "0.00",
            self_closing: "true"
          }
        }
      end

      it "returns the insurance party method failed" do
        VCR.use_cassette("amd/add_insurance_failure") do
          insurance_detail = insurance.add_insurance(params)

          expect(insurance_detail["@id"]).to be_nil
          expect(insurance_detail["Fault"]).to be_present
        end
      end
    end
  end
end
