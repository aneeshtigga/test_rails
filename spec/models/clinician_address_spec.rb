# == Schema Information
# Schema version: 20230330105145
#
# Table name: clinician_addresses
#
#  id               :bigint           not null, primary key
#  address_code     :string
#  address_line1    :string           not null
#  address_line2    :string
#  apt_suite        :string
#  area_code        :string
#  cbo              :integer
#  city             :string           not null
#  country_code     :string
#  deleted_at       :datetime         indexed, indexed => [postal_code]
#  facility_name    :string
#  latitude         :float            indexed
#  longitude        :float            indexed
#  office_key       :bigint           indexed => [provider_id, facility_id]
#  postal_code      :string           indexed, indexed => [deleted_at]
#  primary_location :boolean          default(TRUE)
#  state            :string           not null, indexed
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  clinician_id     :bigint           not null, indexed
#  facility_id      :bigint           indexed => [provider_id, office_key]
#  provider_id      :bigint           indexed => [facility_id, office_key]
#
# Indexes
#
#  index_clinician_addresses_on_clinician_id                (clinician_id)
#  index_clinician_addresses_on_deleted_at                  (deleted_at)
#  index_clinician_addresses_on_latitude                    (latitude)
#  index_clinician_addresses_on_longitude                   (longitude)
#  index_clinician_addresses_on_pid_fid_lk                  (provider_id,facility_id,office_key)
#  index_clinician_addresses_on_postal_code                 (postal_code)
#  index_clinician_addresses_on_postal_code_and_deleted_at  (postal_code,deleted_at)
#  index_clinician_addresses_on_state                       (state)
#
# Foreign Keys
#
#  fk_rails_...  (clinician_id => clinicians.id)
#
require "rails_helper"

RSpec.describe ClinicianAddress, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    travel_to stub_time
  end

  after do
    travel_back
  end

  context "#license_key" do
    let(:clinician_address) { build(:clinician_address, office_key: 123456) }

    it "returns the office key" do
      expect(clinician_address.license_key).to eq(clinician_address.office_key)
    end
  end

  context "validations" do
    let!(:clinician) { create(:clinician_address, address_code: create(:address_type).code) }

    it "is valid with valid attributes" do
      expect(ClinicianAddress.first).to be_valid
    end

    it "is not valid without address_line1" do
      expect { ClinicianAddress.first.update!(address_line1: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "is not valid without city" do
      expect { ClinicianAddress.first.update!(city: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "is not valid without state" do
      expect { ClinicianAddress.first.update!(state: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "is not valid without clinician" do
      expect { ClinicianAddress.first.update!(clinician_id: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "associations" do
    it "should belongs to addressable record" do
      t = ClinicianAddress.reflect_on_association(:clinician)
      expect(t.macro).to eq(:belongs_to)
    end
    it { should have_many(:clinician_availabilities) }
  end

  context "scopes" do
    describe ".with zip code" do
      it "filters addresses by zip code" do
        address1 = create(:clinician_address, postal_code: "53001", address_line1: "3rd avenue")
        address2 = create(:clinician_address, postal_code: "33010", address_line1: "4th avenue")
        expect(ClinicianAddress.with_zip_code(address1.postal_code).size).to eq(1)
        expect(ClinicianAddress.with_zip_code(address1.postal_code).first.address_line1).to eq(address1.address_line1)
      end
    end

    describe ".with_insurances" do
      let!(:unmatching_address) { create(:clinician_address) }
      let!(:unmatching_insurance) { create(:insurance, name: "Aetna") }
      let!(:unmatching_facility_accepted_insurance) do
        create(:facility_accepted_insurance, insurance: unmatching_insurance, clinician_address: unmatching_address)
      end

      let!(:matching_address) { create(:clinician_address, facility_id: 23_456) }
      let!(:matching_insurance) { create(:insurance) }
      let!(:matching_facility_accepted_insurance) do
        create(:facility_accepted_insurance, insurance: matching_insurance, clinician_address: matching_address)
      end

      context "when app_name is obie" do
        it "filters addresses by supported insurances" do
          expect(ClinicianAddress.with_insurances(matching_insurance.name, "obie").count).to be < (ClinicianAddress.count)
          expect(ClinicianAddress.with_insurances(matching_insurance.name, "obie")).to match_array([matching_address])
        end
      end

      context "when app_name is abie" do
        it "filters addresses by supported insurances" do
          expect(ClinicianAddress.with_insurances(matching_insurance.name, "abie").count).to be 0
          expect(ClinicianAddress.with_insurances(matching_insurance.name, "abie")).to be_empty
        end
      end
    end

    describe ".with_facility_ids" do
      it "filters addresses by facility ids" do
        matching_address = create(:clinician_address, facility_id: 12_345,
                                                      address_line1: "3rd avenue")
        unmatched_address2 = create(:clinician_address, facility_id: 67_890,
                                                        address_line1: "4th avenue")

        expect(ClinicianAddress.with_facility_ids(12_345)).to match_array([matching_address])
      end
    end

    describe "type_of_care_criteria" do
      let!(:matching_address) { create(:clinician_address, facility_id: 12_345) }
      let!(:matching_care) do
        create(:type_of_care, facility_id: matching_address.facility_id, type_of_care: "Adult Theraphy")
      end

      let!(:unmatched_address) { create(:clinician_address) }
      let!(:unmatched_care) { create(:type_of_care, facility_id: unmatched_address.facility_id) }

      it "returns the criteria for type_of_care querying" do
        expect(ClinicianAddress.type_of_care_criteria(matching_care.type_of_care)).to match_array(matching_address)
      end
    end

    describe ".active" do
      it "filters the active addresses" do
        active_address = create(:clinician_address)
        inactive_address = create(:clinician_address, deleted_at: Time.now.utc)
        expect(ClinicianAddress.active).to include(active_address)
      end
    end

    describe ".before_time_appointment_availability" do
      it "returns no availabilities within the next 24 hours in weekday" do
        clinician_address_current_day = create(:clinician_address)
        expect(ClinicianAddress.before_time_appointment_availability(Time.zone.now)).not_to include(clinician_address_current_day)
      end

      it "returns no availabilities within the next 24 hours on Friday" do
        travel_to Time.new(2021, 12, 3, 9, 0, 0, "utc") # Friday
        clinician_address_current_day = create(:clinician_address)
        expect(ClinicianAddress.before_time_appointment_availability(Time.zone.now)).not_to include(clinician_address_current_day)
      end

      it "returns availabilities after the next 24 hours on weekdays" do
        clinician_availability = create(:clinician_availability,
                                        appointment_start_time: Time.new(2021, 12, 3, 10, 0, 0, "utc"))
        clinician_address_after_24_hours = create(:clinician_address,
                                                  clinician_availabilities: [clinician_availability])
        expect(ClinicianAddress.before_time_appointment_availability((Time.new(2021, 12, 4, 12, 0, 0,
                                                                               "utc")))).to include(clinician_address_after_24_hours)
      end

      it "returns availabilities after the next 24 hours on Friday" do
        travel_to Time.new(2021, 12, 3, 9, 0, 0, "utc") # Friday
        clinician_availability = create(:clinician_availability,
                                        appointment_start_time: Time.new(2021, 12, 6, 10, 0, 0, "utc"))
        clinician_address_after_24_hours = create(:clinician_address,
                                                  clinician_availabilities: [clinician_availability])
        expect(ClinicianAddress.before_time_appointment_availability((Time.new(2021, 12, 8, 12, 0, 0,
                                                                               "utc")))).to include(clinician_address_after_24_hours)
      end
    end

    describe "availability_between_time" do
      let!(:address) { create(:clinician_address, :with_clinician_availability) }
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "returns addresses after the specific time" do
        date_time = DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days
        address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc + 15.minutes)

        expect(ClinicianAddress.availability_between_time(date_time, date_time.end_of_day).count).to eq(1)
        expect(ClinicianAddress.availability_between_time(date_time, date_time.end_of_day)).to include(address)
      end

      it "should not returns addresses before the specific time" do
        date_time = DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days
        address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc - 1.hour)

        expect(ClinicianAddress.availability_between_time(date_time, date_time.end_of_day).count).to eq(0)
        expect(ClinicianAddress.availability_between_time(date_time, date_time.end_of_day)).to be_empty
      end
    end

    describe "availability_till_date" do
      let!(:address) { create(:clinician_address, :with_clinician_availability) }
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "returns addresses with addresses before till date" do
        till_date = DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days
        address.clinician_availabilities.first.update!(appointment_start_time: till_date.utc - 10.minutes)

        expect(ClinicianAddress.availability_till_date(till_date).count).to eq(1)
        expect(ClinicianAddress.availability_till_date(till_date)).to include(address)
      end

      it "should not returns addresses after the till date" do
        till_date = DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days
        address.clinician_availabilities.first.update!(appointment_start_time: till_date.utc + 10.minutes)

        expect(ClinicianAddress.availability_till_date(till_date).count).to eq(0)
        expect(ClinicianAddress.availability_till_date(till_date)).to be_empty
      end
    end

    describe "with_in_office_availabilities" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) do
        create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                        provider_id: address.provider_id)
      end
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "should return addresses with in_office availabilities" do
        availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
        availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

        expect(ClinicianAddress.with_in_office_availabilities.count).to eq(1)
        expect(ClinicianAddress.with_in_office_availabilities.first).to eq(availability.clinician_addresses.first)
      end
    end

    describe "with_virtual_visit_availabilities" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) do
        create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                        provider_id: address.provider_id)
      end
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "should return addresses with video_visit availabilities" do
        availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
        availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

        expect(ClinicianAddress.with_virtual_visit_availabilities.count).to eq(1)
        expect(ClinicianAddress.with_virtual_visit_availabilities.first).to eq(availability2.clinician_addresses.first)
      end
    end

    describe "with_modality_availabilities" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) do
        create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                        provider_id: address.provider_id)
      end
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "should return addresses with both virtual and in office supported modalities" do
        availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
        availability2.update(virtual_or_video_visit: 1, in_person_visit: 1)
        expect(ClinicianAddress.with_modality_availabilities.count).to eq(2)
        expect(ClinicianAddress.with_modality_availabilities.last).to eq(availability2.clinician_addresses.first)
      end
    end

    describe "patient clinician address" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) do
        create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                        provider_id: address.provider_id, reason: "TELE", is_ia: 0, is_fu: 1)
      end
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let!(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729, is_ia: 1, is_fu: 0) }

      it "should return availabilities for new patient" do
        expect(ClinicianAddress.new_patient_clinician_availabilities.count).to eq(1)
        expect(ClinicianAddress.new_patient_clinician_availabilities.first).to eq(address2)
      end

      it "should return availabilities for existing patient" do
        expect(ClinicianAddress.existing_patient_clinician_availabilities.count).to eq(1)
        expect(ClinicianAddress.existing_patient_clinician_availabilities.first).to eq(address)
      end
    end

    describe "create_active_license_keys" do
      before do 
        LicenseKey.delete_all
      end

      it "create a license key record when a clinician address with new office key is created" do
        license_key_before_count = LicenseKey.count
        create(:clinician_address)
        expect(LicenseKey.count).to be > license_key_before_count
      end
    end

    describe "refresh_license_keys" do
      it "creates license key records for existing clinician addresses if not present" do
        create(:clinician_address, office_key: 995456)
        create(:clinician_address, office_key: 996075)
        LicenseKey.delete_all
        license_key_before_count = LicenseKey.count
        ClinicianAddress.refresh_license_keys
        expect(LicenseKey.count).to be > license_key_before_count
      end
    end

    describe ".with_active_office_keys" do
      it "returns clinician addresses with active license key" do
        address1 = create(:clinician_address, office_key: 995456)
        expect(ClinicianAddress.with_active_office_keys).to include address1
        LicenseKey.find_by(key: address1.office_key).update(active: false)
        expect(ClinicianAddress.with_active_office_keys).to_not include address1
      end
    end

    describe ".with_care" do
      let(:address) { create(:clinician_address) }
      let(:insurance) { create(:insurance, name: "Anthem") }
      let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, insurance: insurance, clinician_address: address) }
      let(:care) { create(:type_of_care, facility_id: address.facility_id, amd_license_key: address.office_key, clinician_id: address.clinician_id) }

      it "returns clinician_addresses which supports the specific care" do
        expect(ClinicianAddress.with_care(care.type_of_care)).to include(address)
      end
    end

    describe "distance_between_two_points" do
      it "finds distance between two points" do
        postal_code = create(:postal_code)
        clinician_address = create(:clinician_address)
        expect(ClinicianAddress.distance_between_two_points([postal_code.latitude, postal_code.longitude],
                                                            [clinician_address.latitude, clinician_address.longitude])).to eq(2754.35)
      end
    end

    describe "update_coordinates_data" do
      it "update coordinates data" do
        clinician_address = create(:clinician_address, latitude: nil, longitude: nil)
        VCR.use_cassette("clinician_address_update_coordinate") do
          clinician_address.update_coordinates_data

          expect(clinician_address.latitude).to   eq(27.977)
          expect(clinician_address.longitude).to  eq(-81.769)
        end
      end
    end
  end

  context "soft deletable" do
    it "is soft_deletable" do 
      clinician_address = create(:clinician_address)

      expect(clinician_address.respond_to?(:soft_deletable?)).to  eq(true)
      expect(clinician_address.soft_deletable?).to                eq(true)
    end    
  end


  ################################################################
  context "Geokit::Mappable" do 
    it 'has correct lat/lng column names at the class level' do 
      expect(ClinicianAddress.lat_column_name).to eq('latitude')
      expect(ClinicianAddress.lng_column_name).to eq('longitude')
    end
  end
end
