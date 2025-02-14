require "rails_helper"

describe ClinicianSearch, clinician_search: true do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    Clinician.destroy_all 
    
    travel_to stub_time

    pc = PostalCode.find_by(zip_code: "90210")
    unless pc.present?
      pc = FactoryBot.create(:postal_code, zip_code: 90210)
    end
  end

  after do
    travel_back
  end

  describe "filter_results method will returns clinician records" do
    context "Method cases which will return clinician records" do
      it "if no params passed result will passed all clinician records" do
        Clinician.destroy_all

        clinician = create(:clinician, :with_address)
        clinician2 = create(:clinician, :with_address)
        language = create(:language)
        create(:clinician_language, clinician: clinician, language: language)
        clinician_records = Clinician.all
        clinician_results = ClinicianSearch.search
        
        expect(Clinician.all).to eq([clinician, clinician2])
        expect(clinician_results.size).to eql(clinician_records.size)
        expect(clinician_results.first).to be_a(Clinician)
        expect(clinician_results.first).to be_a(ApplicationRecord)
      end

      it "if languages params passed as English result will passed all clinician records who spoke English" do
        clinician = create(:clinician, :with_address)
        create(:clinician_language, clinician: clinician)
        clinician_results = ClinicianSearch.search({ languages: "english" })
        expect(clinician_results.first).not_to be(nil)
        language_spoken = clinician_results.first.languages.first.name
        expect(language_spoken).to eql("English")
      end

      it "if expertises params passed as MD result will passed all clinician records who spoke ND" do
        clinician = create(:clinician, :with_address)
        create(:clinician_expertise, clinician: clinician)
        clinician_results = ClinicianSearch.search({ expertises: "MD" })
        expect(clinician_results.first).not_to be(nil)
        language_spoken = clinician_results.first.expertises.first.name
        expect(language_spoken).to eql("MD")
      end

      it "if clinician_types params passed as Adult Therapy result will passed all clinicial records who have clinician_type Adult Therapy" do
        create(:clinician, :with_address)
        clinician_results = ClinicianSearch.search({ clinician_types: "Adult Therapy" })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.clinician_type).to eql("Adult Therapy")
      end

      it "if clinician_types params passed as Adult Therapy which is present and languages which user spoke will return the records" do
        clinician = create(:clinician, :with_address)
        create(:clinician_language, clinician: clinician)
        clinician_results = ClinicianSearch.search({ clinician_types: "Adult Therapy", languages: "english" })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first).to be_a(Clinician)
      end

      it "if expertises params passed as MD which is present and clinician_types passed as Adult Therapy will return the records" do
        clinician = create(:clinician, :with_address)
        create(:clinician_expertise, clinician: clinician)
        clinician_results = ClinicianSearch.search({ expertises: "MD", clinician_types: "Adult Therapy" })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first).to be_a(Clinician)
      end

      it "if concerns params passed as MD which is present and clinician_types passed as Adult Therapy will return the records" do
        concern = create(:concern, name: "MD")
        clinician = create(:clinician, :with_address)
        create(:clinician_concern, clinician: clinician, concern: concern)
        clinician_results = ClinicianSearch.search({ concerns: "MD", clinician_types: "Adult Therapy" })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first).to be_a(Clinician)
      end

      it "if availability time filter params result will return the records" do
        clinician = create(:clinician, :with_address)
        create(:clinician_expertise, clinician: clinician)
        availability_filters = %w[before_12_PM after_3_PM next_week]
        clinician_results = ClinicianSearch.search({ expertises: "MD", clinician_types: "Adult Therapy", availability_filter: availability_filters })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first).to be_a(Clinician)
      end

      it "if availability time filter params have before filter result will return the records before that filter hour" do
        clinician = create(:clinician, :with_address)
        create(:clinician_expertise, clinician: clinician)
        availability_filters = %w[before_12_PM after_3_PM next_week]
        clinician_results = ClinicianSearch.search({ expertises: "MD", clinician_types: "Adult Therapy", availability_filter: availability_filters })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first).to be_a(Clinician)
      end



      it "return clinicians who have addresses at passed zip_code param" do
        skip "Search method does not use zip_codes, entire_state filters"

        zip_code = "30301"
        address = create(:clinician_address, clinician: create(:clinician, :with_address), postal_code: zip_code)
        clinician = address.clinician

        # SMELL:  The search method does not have a filter for
        #         zip_codes.

        clinician_results = ClinicianSearch.search({ zip_codes: zip_code })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.id).to eq(clinician.id)
      end

      it "returns clinicians whose first name matches the search term" do
        skip "Bad Test Data - need zip codes with search term"

        _non_matching_clinician = create(:clinician, :with_address)
        matching_clinician = create(:clinician, :with_address, first_name: "David", last_name: "wilson")

        expect(ClinicianSearch.search({ search_term: "david" }).size).to be < Clinician.count
        expect(ClinicianSearch.search({ search_term: "david" })).to match_array([matching_clinician])
      end

      it "returns clinicians whose last name matches the search term" do
        skip "Bad Test Data - need zip codes with search term"

        _non_matching_clinician = create(:clinician, :with_address)
        matching_clinician = create(:clinician, :with_address, first_name: "David", last_name: "wilson")

        expect(ClinicianSearch.search({ search_term: "wilson" }).size).to be < Clinician.count
        expect(ClinicianSearch.search({ search_term: "wilson" })).to match_array([matching_clinician])
      end

      it "returns clinicians whose contacted first name and last name matches the search term" do
        skip "Bad Test Data - need zip codes with search term"

        _non_matching_clinician = create(:clinician, :with_address)
        matching_clinician = create(:clinician, :with_address, first_name: "David", last_name: "wilson")

        expect(ClinicianSearch.search({ search_term: "david wilson" })).to match_array([matching_clinician])
        expect(ClinicianSearch.search({ search_term: "wilson david" })).to match_array([matching_clinician])
        expect(ClinicianSearch.search({ search_term: "David W" })).to match_array([matching_clinician])
        expect(ClinicianSearch.search({ search_term: "Dav" })).to match_array([matching_clinician])
        expect(ClinicianSearch.search({ search_term: "son" })).to match_array([matching_clinician])
      end

      it "will filter clinician by pronouns 'He/is'" do
        clinician = create(:clinician, :with_address, pronouns: "He/His")
        clinician_results = ClinicianSearch.search({ pronouns: ["He/His"] })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.id).to eq(clinician.id)
      end

      it "will filter clinician by genders 'Female', 'F'" do
        clinician = create(:clinician, :with_address, gender: "Female")
        clinician_results = ClinicianSearch.search({ gender: ["Female", "F"] })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.id).to eq(clinician.id)
      end

      it "will filter clinician by genders 'Male', 'M'" do
        clinician = create(:clinician, :with_address, gender: "Male")
        clinician_results = ClinicianSearch.search({ gender: ["Male", "M"] })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.id).to eq(clinician.id)
      end

      it "will filter clinician by genders 'Non-binary'" do
        clinician = create(:clinician, :with_address, gender: "Non-binary")
        clinician_results = ClinicianSearch.search({ gender: ["Non-binary"] })
        expect(clinician_results.first).not_to be(nil)
        expect(clinician_results.first.id).to eq(clinician.id)
      end

      it "will filter clinician by genders 'Male' or 'Non-binary'" do
        clinician = create(:clinician, :with_address, gender: "Non-binary")
        clinician2 = create(:clinician, :with_address, gender: "Male")
        clinician_results = ClinicianSearch.search({ gender: ["Non-binary", "Male"] })

        expect(clinician_results.size).to eq(2)
      end

      it "will filter clinician by pronoun 'He/His' && 'She/her'" do
        clinician = create(:clinician, :with_address, pronouns: "He/His")
        clinician2 = create(:clinician, :with_address, pronouns: "Her/She")
        clinician_results = ClinicianSearch.search({ pronouns: ["Her/She", "He/His"] })
        expect(clinician_results.size).to eq(2)
        expect(clinician_results.first.pronouns).to eq(clinician.pronouns)
        expect(clinician_results.last.pronouns).to eq(clinician2.pronouns)
      end

      it "will filter clinician by pronoun 'He/His' case insensitive" do
        clinician = create(:clinician, :with_address, pronouns: "he/his")
        clinician_results = ClinicianSearch.search({ pronouns: ["Her/She", "He/His"] })
        expect(clinician_results.size).to eq(1)
        expect(clinician_results.first.pronouns).to eq(clinician.pronouns)
      end
    end

    context "Method cases which will not return any record" do
      it "if languages params passed as any language that is not present it will return blank record" do
        clinician = create(:clinician, :with_address)
        create(:clinician_language, clinician: clinician)
        clinician_results = ClinicianSearch.search({ languages: "Russian" })
        expect(clinician_results.first).to be(nil)
      end

      it "if clinician_type params passed as any clinician_types that is not present it will return blank record" do
        create(:clinician, :with_address)
        clinician_results = ClinicianSearch.search({ clinician_types: "Child Therapy" })
        expect(clinician_results.first).to be(nil)
      end

      it "if clinician_types params passed as Adult Therapy which is present but languages which user does not spoke will return no records" do
        clinician = create(:clinician, :with_address)
        create(:clinician_language, clinician: clinician)
        clinician_results = ClinicianSearch.search({ clinician_types: "Adult Therapy", languages: "Russian" })
        expect(clinician_results.first).to be(nil)
      end

      it "if clinician_types params passed as Child Therapy which is not present and languages which user spoke will return no records" do
        create(:clinician_language)
        clinician_results = ClinicianSearch.search({ clinician_types: "Child Therapy", languages: "English" })
        expect(clinician_results.first).to be(nil)
      end

      it "if expertises params passed as MD and languages English as there are no clinicial which has both feature will return no records" do
        create(:clinician_expertise)
        clinician_results = ClinicianSearch.search({ expertises: "MD", languages: "English" })
        expect(clinician_results.first).to be(nil)
      end

      it "if expertises params passed as MD, languages spoken as English and clinician_types as Adult Therapy
          no clinician which has all feature will return no records" do
        create(:clinician_language)
        create(:clinician_expertise)
        clinician_results = ClinicianSearch.search({ expertises: "MD", languages: "English",
                                                     clinician_types: "Adult Therapy" })
        expect(clinician_results.first).to be(nil)
      end

      it "will filter clinician by pronouns She/her" do
        _clinician = create(:clinician, pronouns: "He/his")
        clinician_results = ClinicianSearch.search({ pronouns: "She/her" })
        expect(clinician_results.first).to be(nil)
      end

      it "will filter clinician by pronouns Them/they" do
        _clinician = create(:clinician, pronouns: "He/his")
        _clinician2 = create(:clinician, pronouns: "She/her")
        clinician_results = ClinicianSearch.search({ pronouns: "Them/they" })
        expect(clinician_results.first).to be(nil)
      end
    end

    describe ".clinicians_by_location" do
      context "clinician has many locations for a zipcode" do
        it "returns a clinician record for each matching address" do
          zip_code = "30331"
          postal_code = create(:postal_code, zip_code: zip_code)
          facility_name = "location 1"
          facility_name2 = "location 2"
          matching_clinician = create(:clinician, :with_address)

          _address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name,
                                                postal_code: zip_code)

          _second_address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name2,
                                                       postal_code: zip_code)

          search_params = {
            zip_codes: [zip_code],
            location_names: [facility_name, facility_name2]
          }
          clinicians = ClinicianSearch.clinicians_by_location(search_params)

          expect(clinicians.map(&:facility_name)).to match_array([facility_name, facility_name2])
        end

        it "returns a clinician record for the matched address" do
          zip_code = "30331"
          postal_code = create(:postal_code, zip_code: zip_code)
          facility_name = "location 1"
          facility_name2 = "location 2"
          matching_clinician = create(:clinician, :with_address)
          non_matching_zipcode = "12345"

          _address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name,
                                                postal_code: zip_code)

          _second_address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name2,
                                                       postal_code: zip_code)

          _not_matching_address = create(:clinician_address, clinician: matching_clinician,
                                                             postal_code: non_matching_zipcode)

          search_params = {
            zip_codes: [zip_code],
            location_names: [facility_name]
          }
          clinicians = ClinicianSearch.clinicians_by_location(search_params)

          expect(clinicians.map(&:facility_name)).to match_array([facility_name])
        end

        it "returns a clinician record for the matched facility" do
          zip_code = "30331"
          postal_code = create(:postal_code, zip_code: zip_code)
          facility_name = "location 1"
          facility_name2 = "location 2"
          matching_clinician = create(:clinician, :with_address)
          non_matching_zipcode = "12345"
          matching_facility_id = 1
          _address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name, facility_id: matching_facility_id,
                                                postal_code: zip_code)
          _second_address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name2, facility_id: 200,
                                                       postal_code: zip_code)
          _not_matching_address = create(:clinician_address, clinician: matching_clinician,
                                                             postal_code: non_matching_zipcode)

          search_params = {
            zip_codes: [zip_code],
            facility_ids: [matching_facility_id]
          }
          clinicians = ClinicianSearch.clinicians_by_location(search_params)

          expect(clinicians.map(&:facility_name)).to match_array([facility_name])
        end

        it "returns clinician records for the matching zip code" do
          zip_code = "30331"
          postal_code = create(:postal_code, zip_code: zip_code)
          facility_name = "location 1"
          facility_name2 = "location 2"
          matching_clinician = create(:clinician, :with_address)
          non_matching_zipcode = "12345"

          _address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name,
                                                postal_code: zip_code)
          _second_address = create(:clinician_address, clinician: matching_clinician, facility_name: facility_name2,
                                                       postal_code: zip_code)
          _not_matching_address = create(:clinician_address, clinician: matching_clinician,
                                                             postal_code: non_matching_zipcode)

          search_params = {
            zip_codes: [zip_code]
          }
          clinicians = ClinicianSearch.clinicians_by_location(search_params)

          expect(clinicians.map(&:facility_name)).to match_array([facility_name, facility_name2])
        end


        it "returns clinician records for the matching state" do
          zip_code        = "30331"
          same_state      = "XX"

          postal_code     = create(:postal_code,
                                    zip_code: zip_code,
                                    state:    same_state)

          facility_name1  = "location 1"
          facility_name2  = "location 2"
          facility_name3  = "location 3"
          facility_name4  = "location 4"

          matching_clinician      = create(:clinician, :with_address)
          non_matching_clinician  = create(:clinician, :with_address)
          put_of_state_clinician  = create(:clinician, :with_address)

          non_matching_zipcode  = "12345"
          non_matching_state    = "ZZ"

          _address1 = create(:clinician_address, 
                              clinician:      matching_clinician, 
                              facility_name:  facility_name1,
                              postal_code:    zip_code,
                              state:          same_state)
          
          _address2 = create(:clinician_address, 
                              clinician:      matching_clinician, 
                              facility_name:  facility_name2,
                              postal_code:    zip_code,
                              state:          same_state)
          
          _address3 = create(:clinician_address, 
                              clinician:      non_matching_clinician,
                              facility_name:  facility_name3,
                              postal_code:    non_matching_zipcode,
                              state:          same_state)

          _address4 = create(:clinician_address, 
                              clinician:      put_of_state_clinician,
                              facility_name:  facility_name4,
                              postal_code:    non_matching_zipcode,
                              state:          non_matching_state)

          search_params = {
            zip_codes:    zip_code,
            entire_state: true
          }

          clinician_addresses = ClinicianSearch.clinicians_by_location(search_params)

          results   = clinician_addresses.map(&:facility_name)
          expected  = [facility_name1, facility_name2, facility_name3]
        
          # FIXME:  This failure demostrates the duplicates
          expect(results.sort).to eq(expected.sort)
        end
      end
    end

    describe ".clinicians_by_ages_accepted" do
      context "clinician has max and min accepted age filter" do
        it "returns a clinician record for min and max accepted age" do
          Clinician.destroy_all

          clinician = create(:clinician, :with_address, ages_accepted: "20-30")

          expect(ClinicianSearch.search({ age: 29 })).to match_array([clinician])
        end

        it "returns no clinician record for max accepted age not in range" do
          Clinician.destroy_all

          _clinician = create(:clinician, :with_address, ages_accepted: "20-30")

          expect(ClinicianSearch.search({ age: 35 })).to be_empty
        end
      end
    end

    describe "clinicians_by_availabilities" do
      context "availability_by_time" do
        let!(:address)      { create(:clinician_address, :with_clinician_availability) }
        let!(:address2)     { create(:clinician_address, :with_clinician_availability, facility_id: 123, office_key: 45678, provider_id: 1729) }
        let(:availability)  { create(:clinician_availability, facility_id: 123, license_key: 45678, provider_id: 1729) }

        it "should return clinician_addresses by availability time" do
          date_time = DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["before_10_AM"] })

          expect(clinician_addresses).to_not be nil
        end

        it "should not return clinician_addresses out of filter time" do
          date_time = DateTime.now.utc.change({ hour: 12, min: 30, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["before_10_AM"] })

          expect(clinician_addresses).to be_empty
        end

        it "should return clinician_addresses after filter time" do
          date_time = DateTime.now.utc.change({ hour: 14, min: 30, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["after_12_PM"] })

          expect(clinician_addresses).to_not be nil
        end

        it "should not return clinician_addresses before filter time" do
          date_time = DateTime.now.utc.change({ hour: 11, min: 30, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["after_12_PM"] })

          expect(clinician_addresses).to be_empty
        end

        it "should return clinician_addresses after filter time" do
          date_time = DateTime.now.utc.change({ hour: 14, min: 30, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["after_12_PM"] })

          expect(addresses).to_not be nil
          expect(addresses).to include(address)
        end

        # Testing the OR condition...
        it "should return clinician_addresses results for before and after filter" do
          afternoon = DateTime.now.utc.change({ hour: 14, min: 30, sec: 0 }) + 2.days
          morning   = DateTime.now.utc.change({ hour:  8, min: 30, sec: 0 }) + 2.days
          
          address.clinician_availabilities.first.update!(appointment_start_time:  afternoon.utc)
          address2.clinician_availabilities.first.update!(appointment_start_time: morning.utc)
          
          params = { 
            availability_filter: %w[before_10_AM after_12_PM] 
          }

          clinician_addresses = ClinicianSearch.clinicians_by_location(params)

          expect(clinician_addresses).to_not be nil
          expect(clinician_addresses).to include(address)
          expect(clinician_addresses).to include(address2)
        end
      end

      context "availability_by_day" do
        let!(:address) { create(:clinician_address, :with_clinician_availability) }
        let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45678, provider_id: 1729) }
        let(:availability) { create(:clinician_availability, facility_id: 123, license_key: 45678, provider_id: 1729) }
        let(:date_time) { DateTime.now.utc.change({ hour: 8, min: 30, sec: 0 }) + 2.days }

        it "should return clinician_addresses by availability day" do
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to_not be nil
          expect(clinician_addresses).to include(address)
        end

        it "should return clinician_addresses by availability day and time" do
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: %w[before_8_AM next_three_days] })

          expect(clinician_addresses).to be_empty
        end
      end

      context "three_next_days" do
        let(:availability) { create(:clinician_availability, appointment_start_time: Time.current + 3.days) }
        let!(:address) { create(:clinician_address, clinician_availabilities: [availability]) }

        it "should return availabilities until 3rd business day on monday" do
          travel_to(stub_time - 2.day)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.now.next_occurring(:thursday))
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to include(address)
        end

        it "should not return availabilities out of 3 business day on monday" do
          travel_to(stub_time - 2.day)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.now.next_occurring(:friday))
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to_not include(address)
        end

        it "should return availabilities until 3rd business day on tuesday" do
          travel_to(stub_time - 1.day)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.now.next_occurring(:friday))
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to include(address)
        end

        it "should not return availabilities out of 3 business day on tuesday" do
          travel_to(stub_time - 1.day)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.now.next_occurring(:saturday))
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to_not include(address)
        end

        it "should return availabilities until 3rd business day on Wednesday" do
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 5.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to include(address)
        end

        it "should return availabilities until 3rd business day on Thursday" do
          travel_to(stub_time + 1.day)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 5.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to include(address)
        end

        it "should return availabilities until 3rd business day on Friday" do
          travel_to(stub_time + 2.days)
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 5.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to include(address)
        end

        it "should not return availabilities before 3rd business day on Wednesday" do
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 6.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).not_to include(address)
        end

        it "should not return availabilities before 3rd business day on Thursday" do
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 6.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).not_to include(address)
        end

        it "should not return availabilities before 3rd business day on Friday" do
          address.clinician_availabilities.first.update!(appointment_start_time: Time.current + 6.days)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).not_to include(address)
        end

        it "should not return availabilities on Monday when booking on Saturday" do
          travel_to(stub_time - 4.days) # Saturday

          date_time = DateTime.now.utc.change({ hour: 9, min: 30, sec: 0 }) + 2.days # Monday
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to be_empty
        end

        it "should not return availabilities on Monday when booking on Sunday" do
          travel_to(stub_time - 3.days) # Sunday

          date_time = DateTime.now.utc.change({ hour: 9, min: 30, sec: 0 }) + 1.days # Monday
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to be_empty
        end

        it "should return availabilities on Tuesday when booking on Saturday" do
          travel_to(stub_time - 4.days) # Saturday

          date_time = DateTime.now.utc.change({ hour: 9, min: 30, sec: 0 }) + 3.days # Tuesday
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to_not be nil
          expect(clinician_addresses).to include(address)
        end

        it "should return availabilities on Tuesday when booking on Sunday" do
          travel_to(stub_time - 3.days) # Sunday

          date_time = DateTime.now.utc.change({ hour: 9, min: 30, sec: 0 }) + 2.days # Tuesday
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          clinician_addresses = ClinicianSearch.clinicians_by_location({ availability_filter: ["next_three_days"] })

          expect(clinician_addresses).to_not be nil
          expect(clinician_addresses).to include(address)
        end
      end
    end

    describe "clinician search by modality" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) { create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key, provider_id: address.provider_id) }
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45678, provider_id: 1729) }

      context "search by modality" do
        it "will filter clinician by modality office_visit" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)
          clinician_results = ClinicianSearch.clinicians_by_location({ modality: "in_office" })

          expect(clinician_results.first).not_to be(nil)
          expect(clinician_results.first.id).to eq(address.id)
        end

        it "will filter clinician by modality video_visit" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

          clinician_results = ClinicianSearch.clinicians_by_location({ modality: "video_visit" })
          expect(clinician_results.first).not_to be(nil)
          expect(clinician_results.first.id).to eq(address2.id)
        end

        it "will filter clinician by modality video_visit and office_visit both" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 1)
          clinician_results = ClinicianSearch.clinicians_by_location({ modality: "both" })

          expect(clinician_results.length).to eq(2)
          expect(clinician_results.first).not_to be(nil)
          expect(clinician_results.last.id).to eq(address2.id)
        end

        it "will filter clinician by modality video_visit" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 1)

          clinician_results = ClinicianSearch.clinicians_by_location({ modality: "video_visit" })
          expect(clinician_results.first).not_to be(nil)
          expect(clinician_results.first.id).to eq(address2.id)
        end
      end
    end


    describe "clinician search by concern" do
      let!(:address) { create(:clinician_address) }
      let!(:intervention) { create(:intervention) }
      let!(:availability) { create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key, provider_id: address.provider_id) }
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45678, provider_id: 1729) }

      context "search by intervention" do
        it "will filter clinician by intervention" do
          clinician = create(:clinician, :with_address)
          intervention = create(:intervention, active: true)
          clinician_intervention = create(:clinician_intervention, clinician: clinician, intervention: intervention)
          clinician_results = ClinicianSearch.search({ interventions: intervention.name })

          expect(clinician_results.first).not_to be(nil)
          expect(clinician_results.first.id).to eq(clinician_intervention.clinician_id)
        end

        context "search by population" do
          it "will filter clinician by population" do
            clinician = create(:clinician, :with_address)
            population = create(:population, active: true)
            clinician_population = create(:clinician_population, clinician: clinician, population: population)
            clinician_results = ClinicianSearch.search({ populations: population.name })

            expect(clinician_results.first).not_to be(nil)
            expect(clinician_results.first.id).to eq(clinician_population.clinician_id)
          end
        end
      end
    end


    describe "clinician search by credentials" do
      # Scenario: 3 clinicians with different credentials

      before do

        lt_ma = LicenseType.find_or_create_by( name: "MA")
        lt_md = LicenseType.find_or_create_by( name: "MD")
        lt_ms = LicenseType.find_or_create_by( name: "MS")

        ma_clinician = FactoryBot.create(:clinician, :active, license_type: "MA")
        md_clinician = FactoryBot.create(:clinician, :active, license_type: "MD")
        ms_clinician = FactoryBot.create(:clinician, :active, license_type: "MS")

        FactoryBot.create(
          :clinician_license_type, 
          clinician:     ma_clinician, 
          license_type:  lt_ma
        ) 

        FactoryBot.create(
          :clinician_license_type, 
          clinician:     md_clinician, 
          license_type:  lt_md
        ) 

        FactoryBot.create(
          :clinician_license_type, 
          clinician:     ms_clinician, 
          license_type:  lt_ms
        ) 
      end

      # NOTE: This context makes use of the ClinicianSearch.search
      #       method which is ONLY used in spec files to simplify
      #       the test data.  In production the method used by
      #       controller is ClinicianSearch.clinicians_by_location which
      #       call the search method within its context.
      #
      context "search by credentials" do
        it "filters usine one credential" do
          results = ClinicianSearch.search(credentials: "MD")

          expect(results.size).to eq(1)
          expect(results.first.license_types.first.name).to eq("MD")
        end

        it "filters usine one credential" do
          results = ClinicianSearch.search(credentials: ["MA", "MD"])

          expect(results.size).to eq(2)
          expect(results.map{|c| c.license_types.first.name}.sort).to eq(["MA", "MD"])
        end

        it "filters usine one credential" do
          results = ClinicianSearch.search(credentials: ["MA", "MD", "MS"])

          expect(results.size).to eq(3)
          expect(results.map{|c| c.license_types.first.name}.sort).to eq(["MA", "MD", "MS"])
        end
      end
    end
  end  
end
