# spec/data_imports/clinician_location_sync_spec.rb

require "rails_helper"

RSpec.describe ClinicianLocationSync do
  
  before :all do
    ClinicianAddress.skip_callback(
                      :commit, 
                      :after, 
                      :update_latitude_longitude, 
                      raise: false
                    )
  end

  describe ".import_data" do
    it "imports the clinician_location_mart data to addresses" do
      clinician = create(:clinician)
      location = create(:clinician_location_mart, clinician_id: clinician.provider_id, facility_id: 1234,
                                                  license_key: clinician.license_key, change_timestamp: Time.now)
      address_count = ClinicianAddress.count
      Sidekiq::Testing.inline! do
        ClinicianLocationSync.import_data
        expect(ClinicianAddress.count).to be > address_count
      end
    end

    it "imports cbo data of clinician address" do
      clinician = create(:clinician)
      location = create(:clinician_location_mart, clinician_id: clinician.provider_id, facility_id: 1234,
                                                  license_key: clinician.license_key, change_timestamp: Time.now)
      Sidekiq::Testing.inline! do
        ClinicianLocationSync.import_data
        expect(ClinicianAddress.count).to eq(1)
        expect(ClinicianAddress.first.cbo).to eq(location.cbo)
      end
    end

    it "doesn't import if cbo is nil" do
      clinician = create(:clinician)
      location = create(:clinician_location_mart, clinician_id: clinician.provider_id, facility_id: 1234,
                        license_key: clinician.license_key, change_timestamp: Time.now, cbo: nil)
      Sidekiq::Testing.inline! do
        ClinicianLocationSync.import_data
        expect(ClinicianAddress.count).to eq(0)
      end
    end

    #######################################################
    ## This context comes from a fire called in which some
    ## information from the ClinicianLocationMart was not
    ## being updated in the ClinicianAddress table.
    ## The test data was provided by the product team as
    ## an example of what is failing.  It is not PII.
    #
    context "Active Clinician w/2 inactive addresses; w/2 locations one-each active/inactive" do

      let(:c_records) {[
        {
          :id                     => 262,
          :first_name             => "Captain",
          :last_name              => "America",
          :clinician_type         => "THERAPIST",
          :license_type           => "MA, LRC",
          :about_the_provider     => "The Captain is GoodToGo",
          :accepting_new_patients => false,
          :in_office              => true,
          :video_visit            => true,
          :manages_medication     => false,
          :ages_accepted          => "18-21, 22-26, 27-40, 41-64, 65+",
          :provider_id            => 1586,
          :npi                    => 666,
          :telehealth_url         => "",
          :gender                 => "Male",
          :created_at             => DateTime.parse("Fri, 10 Sep 2021 22:48:17.944337000 UTC +00:00"),
          :updated_at             => DateTime.parse("Tue, 01 Nov 2022 03:02:20.160278000 UTC +00:00"),
          :pronouns               => "She/Her",
          :deleted_at             => nil,
          :middle_name            => "G",
          :photo                  => "",
          :license_key            => 144557,
          :cbo                    => 138690,
          :online_booking_go_live_date => nil
        }
      ]}


      let(:clm_records) {[
        {
          :license_key      => 144557,
          :clinician_id     => 1586,
          :primary_location => false,
          :facility_name    => "Mclean",
          :facility_id      => 17,
          :cbo              => 138690,
          :apt_suite        => "Ste 666",
          :location         => "123 Any St.",
          :zip_code         => "22101",
          :city             => "Mc Lean",
          :state            => "VA",
          :area_code        => "703",
          :country_code     => "USA",
          :is_active        => 1,
          :create_timestamp => DateTime.parse("Fri, 20 Dec 2019 12:58:16.230000000 UTC +00:00"),
          :change_timestamp => DateTime.parse("Tue, 18 Jan 2022 09:07:31.503000000 UTC +00:00")
        },
        {
          :license_key      => 144557,
          :clinician_id     => 1586,
          :primary_location => false,
          :facility_name    => "Dumfries", # different from above
          :facility_id      => 17,
          :cbo              => 138690,
          :apt_suite        => "Ste 444",
          :location         => "1234 Any Rd.",
          :zip_code         => "22101",
          :city             => "Dumfries",
          :state            => "VA",
          :area_code        => "703",
          :country_code     => "USA",
          :is_active        => 0,
          :create_timestamp => DateTime.parse("Fri, 20 Dec 2019 12:58:16.230000000 UTC +00:00"),
          :change_timestamp => DateTime.parse("Tue, 18 Jan 2022 09:07:31.503000000 UTC +00:00")
        }
      ]}

      let(:ca_records) {[
        {
          :id               => 802,
          :address_line1    => "123 Rd",
          :address_line2    => nil,
          :city             => "Mc Lean",
          :state            => "VA",
          :postal_code      => "22101",
          :clinician_id     => 262,
          :created_at       => DateTime.parse("Sun, 12 Sep 2021 15:12:26.495875000 UTC +00:00"),
          :updated_at       => DateTime.parse("Thu, 12 Jan 2023 23:10:51.421774000 UTC +00:00"),
          :address_code     => nil,
          :office_key       => 144557,
          :facility_id      => 17,
          :primary_location => true,
          :facility_name    => "Mclean",
          :apt_suite        => "Ste 123",
          :country_code     => "USA",
          :area_code        => "703",
          :provider_id      => 1586,
          :deleted_at       => DateTime.parse("Thu, 12 Jan 2023 23:10:51.421264000 UTC +00:00"),
          :cbo              => 138690,
          :latitude         => 37.35855,
          :longitude        => -81.647033
        },
        {
          :id               => 13927,
          :address_line1    => "123 Any Street",
          :address_line2    => nil,
          :city             => "Mc Lean",
          :state            => "VA",
          :postal_code      => "22101",
          :clinician_id     => 262,
          :created_at       => DateTime.parse("Thu, 12 Jan 2023 23:15:06.018616000 UTC +00:00"),
          :updated_at       => DateTime.parse("Thu, 12 Jan 2023 23:15:06.018616000 UTC +00:00"),
          :address_code     => nil,
          :office_key       => 144557,
          :facility_id      => 17,
          :primary_location => true,
          :facility_name    => "Mclean",
          :apt_suite        => "Ste 321",
          :country_code     => "USA",
          :area_code        => "703",
          :provider_id      => 1586,
          :deleted_at       => DateTime.parse("Thu, 12 Jan 2023 23:15:06.018181000 UTC +00:00"),
          :cbo              => 138690,
          :latitude         => nil,
          :longitude        => nil
        }
      ]}



      before :each do
        Clinician.destroy_all
        ClinicianLocationMart.destroy_all
        ClinicianAddress.destroy_all

        c_records.each do |attributes|
          create(:clinician, attributes)
        end

        clm_records.each do |attributes|
          create(:clinician_location_mart, attributes)
        end

        ca_records.each do |attributes|
          create(:clinician_address, attributes)
        end
      end


      it "verify test data is as expected" do
        expect(Clinician.unscoped.count).to             eq(c_records.size)
        expect(ClinicianLocationMart.unscoped.count).to eq(clm_records.size)
        expect(ClinicianAddress.unscoped.count).to      eq(ca_records.size)
      end


      it "processes 1 active ClinicianLocationMart by adding 1 new ClinicianAddress" do
        before_ca_count           = ClinicianAddress.count
        before_ca_unscoped_count  = ClinicianAddress.unscoped.count

        expect(before_ca_unscoped_count).to eq(ca_records.size)

        Sidekiq::Testing.inline! do
          ClinicianLocationSync.import_data(time_since: nil)
        end

        after_ca_count          = ClinicianAddress.count
        after_ca_unscoped_count = ClinicianAddress.unscoped.count

        expect(after_ca_unscoped_count).to eq(before_ca_unscoped_count + clm_records.size - 1) # one was inactive

        # This is predicated upon adding new records
        expect(after_ca_count).to eq(before_ca_count + clm_records.size - 1) # one was inactive
      end
    end
  end

  # The sync_data method orchestrates the private
  # class methods:
  #   add_location
  #   delete_location
  #
  describe ".sync_data" do
    let(:provider_id)     { 100 }
    let(:old_facility_id) { 1 } # used to test delete_location method
    let(:facility_id)     { 2 }
    let(:license_key)     { 10 }
    let(:cbo)             { 149330 }

    let!(:clinician) do
      create(
        :clinician,
        provider_id:  provider_id,
        license_key:  license_key,
        cbo:          cbo
      )
    end

    let!(:location_mart) do
      create(
        :clinician_location_mart,
        clinician_id: provider_id,
        license_key:  license_key,
        facility_id:  facility_id,
        cbo:          cbo
      )
    end

    context "clinician is found" do
      context "address is pre-existing (add_location)" do

        it "does not add new addresses" do
          existing_address  = create(
                                :clinician_address,
                                clinician:    clinician,
                                office_key:   license_key,
                                facility_id:  facility_id,
                                provider_id:  provider_id,
                                cbo:          cbo
                              )

          expect do
            ClinicianLocationSync.sync_data(provider_id, license_key, cbo, facility_id)
          end.not_to change { ClinicianAddress.count }
        end
      end

      context "address is new (add_location)" do

        it "adds a new address" do
          ClinicianLocationSync.sync_data(provider_id, license_key, cbo, facility_id)

          expect(clinician.clinician_addresses.last).to have_attributes(
            primary_location: location_mart.primary_location,
            facility_id:      facility_id,
            facility_name:    location_mart.facility_name,
            provider_id:      provider_id,
            office_key:       license_key,
            address_line1:    location_mart.location,
            apt_suite:        location_mart.apt_suite,
            city:             location_mart.city,
            state:            location_mart.state,
            area_code:        location_mart.area_code,
            postal_code:      location_mart.zip_code,
            deleted_at:       location_mart.deleted_at
          )
        end
      end


      ################################################################
      ## This context tests the delete_location functionality
      #
      context "clinician_address is not in clinician_location_mart" do
        let(:this_provider_id)  { 6502 }

        let(:this_clinician)  { create(
                                  :clinician,
                                  provider_id:  this_provider_id,
                                  license_key:  license_key,
                                  cbo:          cbo
                                )
                              }

        let(:old_office)      { create(
                                  :clinician_address,
                                  provider_id:  this_provider_id,
                                  facility_id:  old_facility_id,
                                  office_key:   license_key,
                                  cbo:          cbo
                                )
                              }


        let(:new_office)      { create(
                                  :clinician_address,
                                  provider_id:  this_provider_id,
                                  facility_id:  facility_id,
                                  office_key:   license_key,
                                  cbo:          cbo
                                )
                              }

      let(:location_mart) { create(
                              :clinician_location_mart,
                              clinician_id:     this_provider_id,
                              facility_id:      facility_id,
                              license_key:      license_key,
                              cbo:              cbo,
                              change_timestamp: Time.now
                            )
                          }

        it "deletes old address (delete_location)" do
          this_clinician.clinician_addresses << old_office
          this_clinician.clinician_addresses << new_office

          before_count  = ClinicianAddress.count

          ClinicianLocationSync.sync_data(
                                      this_provider_id,
                                      license_key,
                                      cbo,
                                      facility_id
                                    )

          after_count   = ClinicianAddress.active.count

          expect(after_count).to eq(before_count - 1)
        end
      end
    end

    context "clinician is not found" do
      it "does not add any addresses" do
        not_existing_provider_id = 200

        expect do
          ClinicianLocationSync.sync_data(not_existing_provider_id, license_key, cbo, facility_id)
        end.not_to change { ClinicianAddress.count }
      end

      context "removing clinician addresses with provider_ids not present on redshift" do
        let(:clinician_address_provider_id) { 975 }

        let!(:postgres_clinician) do
          create(
            :clinician,
            provider_id: clinician_address_provider_id
          )
        end

        let!(:clinician_address) do
          create(
            :clinician_address,
            provider_id: clinician_address_provider_id
          )
        end

        # Non-matching provider id
        let!(:location_mart) do
          create(
            :clinician_location_mart,
            clinician_id: provider_id,
            change_timestamp: Time.current
          )
        end

        it "deletes stale clinician addresses" do

          before_count = ClinicianAddress.count

          ClinicianLocationSync.import_data

          after_count = ClinicianAddress.active.count

          expect(after_count).to eq(before_count - 1)
        end
      end

    end
  end
end
