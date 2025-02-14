require "rails_helper"

describe Abie::V2::CliniciansSearchBuilder, type: :class do
  describe ".build" do
    let!(:postal_code) { create(:postal_code, zip_code: "30301") }

    context "max_clinicians_per_modality is 3" do
      let!(:temp_clinician) { create(:clinician) }
      let!(:temp_address) { create(:clinician_address, clinician: temp_clinician) }
      let!(:temp_care) { create(:type_of_care, facility_id: temp_address.facility_id, clinician: temp_clinician) }
      let!(:params) do
        {
          age: 23,
          payment_type: "self_pay",
          utc_offset: "360",
          zip_codes: "30301",
          type_of_cares: temp_care.type_of_care,
          max_clinicians_per_modality: 3,
        }
      end
      before do
        ClinicianAvailability.destroy_all
        15.times do |num|
          create(
            :clinician_availability,
            provider_id: temp_address.provider_id,
            license_key: temp_address.office_key,
            type_of_care: temp_care.type_of_care,
            in_person_visit: (num+1)%2,
            virtual_or_video_visit: num%2,
            available_date: Time.now.utc + (20.days - num.days)
          )
        end  
      end

      it "will return 6 clinician_availabilities per clinician" do
        clinicians = Abie::V2::CliniciansSearchBuilder.build(params)
        clinicians.each do |clinician|
          expect(clinician["clinician_availabilities"].count).to eq 6
        end
      end

      it "will return at least 3 in_person availabilities for every clinician" do
        clinicians = Abie::V2::CliniciansSearchBuilder.build(params)
        clinicians.each do |clinician|
          in_person_availabilities = get_in_person_availabilities([clinician])
          expect(in_person_availabilities.count).to be >= 3
        end
      end

      it "will return at least 3 virtual availabilities for every clinician" do
        clinicians = Abie::V2::CliniciansSearchBuilder.build(params)
        clinicians.each do |clinician|
          virtual_availabilities = get_virtual_availabilities([clinician])
          expect(virtual_availabilities.count).to be >= 3
        end
      end

      it "will return the soonest availabilities for every clinician" do
        clinicians = Abie::V2::CliniciansSearchBuilder.build(params)

        clinicians.each do |clinician|
          address = ClinicianAddress.find(clinician["addresses"].first["id"])
          actual_soonest_availability_keys = address.clinician_availabilities.sort_by(&:available_date).first(6).pluck(:clinician_availability_key)

          expected_soonest_availability_keys = clinician["clinician_availabilities"].map do |availability|
            availability["clinician_availability_key"].to_d
          end
          expect(actual_soonest_availability_keys).to eq expected_soonest_availability_keys
        end
      end
    end

    context "when max_clinicians_per_modality is not set" do
      let!(:clinician) { create(:clinician) }
      let!(:clinician2) { create(:clinician, :with_address) }
      let!(:address) { create(:clinician_address, :with_clinician_availability, clinician: clinician, postal_code: postal_code.zip_code, state: "AK") }
      let!(:care) { create(:type_of_care, facility_id: address.facility_id, clinician: clinician) }

      let!(:clinician3) { create(:clinician) }
      let!(:address3) { create(:clinician_address, :with_clinician_availability, clinician: clinician3, postal_code: "89015") }
      let!(:care3) { create(:type_of_care, facility_id: address3.facility_id, clinician: clinician3, type_of_care: "Adult Therapy") }
      let!(:clinician_availability3) do
        create(:clinician_availability,
        provider_id: address3.provider_id,
        license_key: address3.office_key,
        type_of_care: care3.type_of_care)
      end
      let!(:params) do
        {
          age: 23,
          payment_type: "self_pay",
          utc_offset: "360",
          zip_codes: "30301",
          type_of_cares: care.type_of_care,
        }
      end

      it "will filter clinicians by zip codes" do
        clinicians = Abie::V2::CliniciansSearchBuilder.build(params)
        clinician_zipcodes = clinicians_address_info(clinicians, :postal_code)
        expect(clinician_zipcodes).to eq ["30301", "30301"] # only 2 clinicians have the params zip_code
      end
    end

  end
end

def clinicians_address_info(clinicians, address_field)
  clinicians.map do |clinician| 
    clinician['addresses'].map do |address|
      address[address_field.to_s]
    end
  end.flatten
end

def get_in_person_availabilities(clinicians)
  availabilities = clinicians.map do |clinician|
    clinician["clinician_availabilities"]
  end
  availabilities.flatten.select { |availability| availability["in_person_visit"] == 1 }
end

def get_virtual_availabilities(clinicians)
  availabilities = clinicians.map do |clinician|
    clinician["clinician_availabilities"]
  end
  availabilities.flatten.select { |availability| availability["virtual_or_video_visit"] == 1 }
end

