require "rails_helper"

RSpec.describe Amd::Api::ResponsiblePartyApi, type: :class do
  describe "#lookup_responsible_party" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    let(:base_url) { "https://provapi.advancedmd.com/processrequest/api-102/LIFESTANCE" }
    let(:token) { "99545677Lknp2nX0NcnIafFSsdEs99RWtbDo1ghj70IuCZlyoML9Re/46Ea8M8TZYl/GHZtnAZA3rwL3PTsg+ubKlndzv1RYqfmXdpzzS3zfTnFU8pGHDIWE88/ptYnBjE+pu4+RWIsbDWU9aTrz8QXVNyd1JZiwU+MLfUALD09OBvV4cMz3pqdemA8cVjz7jhmyzRX3U6wEg5eAEr78dMdwIhMA==" }
    let(:params) do
      {
        first_name: "ADDISON",
        last_name: "ANDRIEU",
        date_of_birth: "01/23/1980"
      }
    end

    let(:responsible_party_api) { Amd::Api::ResponsiblePartyApi.new(config, base_url, token) }

    it "returns the correct responsible_party" do
      VCR.use_cassette('amd/lookup_responsible_party_multiple_returns') do
        responsible_party = responsible_party_api.lookup_responsible_party(params)

        expect(responsible_party).to have_attributes(
          id: "resp6847854",
          name: "ANDRIEU,ADDISON",
          acct_num: "6847854",
          date_of_birth: "01/23/1980",
          gender: "F",
          email: "ANDRIEU.ADDISON@EXAMPLE.COM",
        )
      end
    end

    describe "responsible party is not found" do
      let(:params) do
        {
          first_name: "bren",
          last_name: "bianci",
          date_of_birth: "11/03/1964"
        }
      end

      it "returns nil if responsible_party isn't found" do
        VCR.use_cassette('amd/lookup_responsible_party_not_found') do
          responsible_party = responsible_party_api.lookup_responsible_party(params)

          expect(responsible_party).to be_nil
        end
      end
    end
  end

  describe "#add_responsible_party" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    let(:base_url) { "https://provapi.advancedmd.com/processrequest/api-101/LIFESTANCE" }
    let(:token) { "995456bctAuAB6+BPxl24Ude+kIAdV/JJODiggKjfy9Z6KkdziZDsUYHrGPiVPMmJ6gZcRotcXyH9ODX8CcG0FZr+z3zBqh8p1ytO4JvR07ltz4t+ikFkbS8ngtmOY0FNOoR7NIcQhiu6bR0irUKpvZQzojI68v6CP1eGTq0VSkLayTmMe8mQISD9eGxEOBzVbl1B7" }
    let(:params) do
      {
        patient: {
          respparty: "SELF",
          name: "ami,mon",
          sex: "M",
          relationship: "1",
          hipaarelationship: "18",
          dob: "12/04/1965",
          ssn: "682-39-8688",
          chart: "AUTO",
          profile: "3",
          finclass: "",
          deceased: "",
          title: "MR",
          maritalstatus: "2",
          insorder: "",
          employer: "ibm, inc.",
          address: {
            zip: "38834",
            city: "CORINTH",
            state: "MS",
            address1: "apt b-5",
            address2: "6923 n mountainside dr",
          },
          contactinfo: {
            homephone: "(662) 555-1343",
            officephone: "(662) 555-9238",
            officeext: "213",
            otherphone: "(662) 555-3823",
            othertype: "C",
            email: "monami@example.com"
          }
        },
        respparty: {
          name: "ami,mon",
          accttype: "4",
        }
      }
    end

    let(:responsible_party_api) { Amd::Api::ResponsiblePartyApi.new(config, base_url, token) }

    it "returns the responsible party created" do
      VCR.use_cassette("amd/add_responsible_party_success") do
        responsible_party = responsible_party_api.add_responsible_party(params)

        expect(responsible_party).to include(
          "@id" => be_truthy,
          "@accttype" => be_truthy,
          "@name" => be_truthy,
        )
      end
    end

    describe "responsible party is not created without required params (name)" do
      let(:params) do
        {
          patient: {
            respparty: "something_not_valid",
            name: "ami,mon",
            sex: "M",
            relationship: "1",
            hipaarelationship: "18",
            dob: "12/04/1965",
            ssn: "682-39-8688",
            chart: "AUTO",
            profile: "3",
            finclass: "",
            deceased: "",
            title: "MR",
            maritalstatus: "2",
            insorder: "",
            employer: "ibm, inc.",
            address: {
            },
            contactinfo: {
            }
          },
          respparty: {
            name: "ami,mon",
            accttype: "something_not_valid"
          }
        }
      end
    end
  end

  describe "#get_responsible_party" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    let(:base_url) { "https://provapi.advancedmd.com/processrequest/api-101/LIFESTANCE" }
    let(:token) { "995456grkYawN6JbkQ0IY4VDoCF/+1fOJiMr3voIHM6XHX/RssN0AJ2FpfaNrIB7RY60TVbwFoaUH/zISgd4r1Gu3UoR71Nly0/jlUQfp49PMbIiZDEigQm7NooIIGaEGb0DbxZv3R/BnONS21IVYDTwV/nHW+vTSHoO+53sZu4qTvPjieFGdoEchiwiHs06k8OuutNCra2iQE5q9MKJEIVDo8OA==" }
    let(:responsible_party_api) { Amd::Api::ResponsiblePartyApi.new(config, base_url, token) }
    let(:amd_resppartyid) { "resp6849573" }

    it "returns the responsible party details" do
      VCR.use_cassette("amd/get_responsible_party_success") do
        responsible_party = responsible_party_api.get_responsible_party(amd_resppartyid)

        expect(responsible_party).to include(
          "resppartylist" => {
            "respparty" => be_truthy
          }
        )
      end
    end

    it "returns an error if getting a responsible party is unsuccessful" do
      VCR.use_cassette('amd/get_responsible_party_failure') do
        responsible_party = responsible_party_api.get_responsible_party("non-existent")

        expect(responsible_party["Fault"]).to be_present
      end
    end
  end
end
