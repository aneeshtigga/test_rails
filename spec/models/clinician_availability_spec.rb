require "rails_helper"

RSpec.describe ClinicianAvailability, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday, December 1st, 2021 9:00 UTC

  before do
    travel_to stub_time
  end

  describe "associations" do
    it { should have_many(:clinician_addresses) }
  end

  describe "scopes" do
    describe 'default scope' do
      # Use `let!` to eagerly create these records before each example
      let!(:availability1) do
        create(:clinician_availability,
          clinician_availability_key: 11111,
          appointment_start_time: 2.days.from_now + 2.hours,
          appointment_end_time: 2.days.from_now + 3.hours)
      end
  
      let!(:availability2) do
        create(:clinician_availability,
          clinician_availability_key: 22222,
          appointment_start_time: 2.days.from_now + 2.hours,
          appointment_end_time: 2.days.from_now + 3.hours)
      end
  
      let!(:status) do
        create(:clinician_availability_status,
          available_date: 5.days.from_now,
          status: 1,
          clinician_availability_key: 22222)
      end
  
      it 'includes availabilities not in ClinicianAvailabilityStatus' do
        expect(ClinicianAvailability.all.pluck(:clinician_availability_key)).to include(availability1.clinician_availability_key)
      end
      it 'excludes availabilities that are in ClinicianAvailabilityStatus (Excluding scheduled availabilities)' do
        expect(ClinicianAvailability.all.pluck(:clinician_availability_key)).not_to include(availability2.clinician_availability_key)
      end
  
      it 'returns all availabilities when unscoped is used (Scheduled and Available)' do
        expect(ClinicianAvailability.unscoped.pluck(:clinician_availability_key)).to include(availability1.clinician_availability_key, availability2.clinician_availability_key)
      end
    end

    describe ".active_data" do
      it "returns clinician availabilities after a 24 hour block period" do
        clinician_availability_after_1_day = create(:clinician_availability, appointment_start_time: 1.day.from_now + 2.hours,
                                                                             appointment_end_time: 1.day.from_now + 3.hours)
        clinician_availability_after_2_day = create(:clinician_availability, appointment_start_time: 2.day.from_now + 2.hours,
                                                    appointment_end_time: 2.day.from_now + 3.hours)
        _clinician_availability_within_1_day = create(:clinician_availability, appointment_start_time: 1.hour.from_now,
                                                                               appointment_end_time: 3.hours.from_now)
        _clinician_availability_within_past = create(:clinician_availability, appointment_start_time: 1.day.ago,
                                                                              appointment_end_time: 1.day.ago - 30.minutes)

        expect(ClinicianAvailability.active_data(48, clinician_availability_after_1_day.license_key, clinician_availability_after_1_day.facility_id, clinician_availability_after_1_day.type_of_care).map(&:clinician_availability_key)).to match_array([clinician_availability_after_2_day.clinician_availability_key])
      end

      it "returns clinician availabilities after a 24 hour block period" do
        clinician_availability_after_1_day = create(:clinician_availability, appointment_start_time: 1.day.from_now + 2.hours,
                                                                             appointment_end_time: 1.day.from_now + 3.hours)
        clinician_availability_after_5_day = create(:clinician_availability, appointment_start_time: 5.day.from_now + 2.hours,
                                                    appointment_end_time: 5.day.from_now + 3.hours)
        _clinician_availability_within_1_day = create(:clinician_availability, appointment_start_time: 1.hour.from_now,
                                                                               appointment_end_time: 3.hours.from_now)
        _clinician_availability_within_past = create(:clinician_availability, appointment_start_time: 1.day.ago,
                                                                              appointment_end_time: 1.day.ago - 30.minutes)

        expect(ClinicianAvailability.active_data(48, clinician_availability_after_1_day.license_key, clinician_availability_after_1_day.facility_id, clinician_availability_after_1_day.type_of_care).map(&:clinician_availability_key)).to match_array([clinician_availability_after_5_day.clinician_availability_key])
      end

      it "returns clinician availabilities after a 48/+ hour block period and skip day/days if the next availability falls on a holiday_schedules list" do
        clinician_availability_after_1_day = create(:clinician_availability, appointment_start_time: 1.day.from_now + 2.hours,
                                                    appointment_end_time: 1.day.from_now + 3.hours)
        clinician_availability_after_4_day = create(:clinician_availability, appointment_start_time: 4.day.from_now + 2.hours,
                                                    appointment_end_time: 4.day.from_now + 3.hours)

        create(:holiday_schedule, date: 2.day.from_now, state: 'All')
        expect(ClinicianAvailability.active_data(48, clinician_availability_after_1_day.license_key, clinician_availability_after_1_day.facility_id, clinician_availability_after_1_day.type_of_care).map(&:clinician_availability_key)).to match_array([clinician_availability_after_4_day.clinician_availability_key])


        clinician_availability_after_6_day = create(:clinician_availability, appointment_start_time: 6.day.from_now + 2.hours,
                                                    appointment_end_time: 6.day.from_now + 3.hours)
        create(:holiday_schedule, date: 3.day.from_now, state: 'AL', description: 'optional holiday')
        expect(ClinicianAvailability.active_data(72, clinician_availability_after_1_day.license_key, clinician_availability_after_1_day.facility_id, clinician_availability_after_1_day.type_of_care).map(&:clinician_availability_key)).to match_array([clinician_availability_after_6_day.clinician_availability_key])
      end

      it "returns clinician availabilities sorted by ascending start time" do
        clinician_availability_after_2_day = create(:clinician_availability, appointment_start_time: 2.day.from_now + 2.hours,
                                                                             appointment_end_time: 2.day.from_now + 3.hours)
        clinician_availability_after_3_day = create(:clinician_availability, appointment_start_time: 3.days.from_now + 1.hour,
                                                                             appointment_end_time: 3.days.from_now + 3.hours)

        expect(ClinicianAvailability.active_data(48, clinician_availability_after_2_day.license_key, clinician_availability_after_2_day.facility_id, clinician_availability_after_2_day.type_of_care).map(&:appointment_start_time)).to eq(
          [clinician_availability_after_2_day.appointment_start_time, clinician_availability_after_3_day.appointment_start_time]
        )
      end

      context "when given 48 hours" do
        let(:block_out_hours) { 48 }
        let(:office_key) { '995456' }

        context "when booking at 11am on Friday" do
          before do
            travel_to Time.new(2021, 12, 3, 11, 0, 0, "utc") # Friday 11am
          end

          let!(:availability_early_tuesday) do 
            create(
              :clinician_availability,
            appointment_start_time: 4.days.from_now - 1.hour,
            appointment_end_time: 4.days.from_now
            )
          end
          let!(:availability_late_tuesday) do
            create(
              :clinician_availability,
              appointment_start_time: 4.days.from_now + 1.hour,
              appointment_end_time: 4.days.from_now + 2.hours
            )
          end
        
          it "first availability will be 11am Tuesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_early_tuesday.facility_id, availability_early_tuesday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_late_tuesday.clinician_availability_key])
            )
          end
        end

        context "when booking at 5pm on Friday" do
          before do
            travel_to Time.new(2021, 12, 3, 17, 0, 0, "utc") # Friday 5pm
          end

          let!(:availability_early_tuesday) do 
            create(
              :clinician_availability,
            appointment_start_time: 4.days.from_now - 1.hour,
            appointment_end_time: 4.days.from_now
            )
          end
          let!(:availability_late_tuesday) do
            create(
              :clinician_availability,
              appointment_start_time: 4.days.from_now + 1.hour,
              appointment_end_time: 4.days.from_now + 2.hours
            )
          end
        
          it "first availability will be 5pm Tuesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_early_tuesday.facility_id, availability_early_tuesday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_late_tuesday.clinician_availability_key])
            )
          end
        end

        context "when booking at 5pm on Thursday" do
          before do
            travel_to Time.new(2021, 12, 2, 17, 0, 0, "utc") # Thursday 5pm
          end

          let!(:availability_late_monday) do 
            create(
              :clinician_availability,
            appointment_start_time: 4.days.from_now - 1.hour,
            appointment_end_time: 4.days.from_now
            )
          end

          let!(:availability_early_tuesday) do 
            create(
              :clinician_availability,
            appointment_start_time: 5.days.from_now - 1.hour,
            appointment_end_time: 5.days.from_now
            )
          end

        
          it "first availability will be 6am Tuesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_late_monday.facility_id, availability_late_monday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_early_tuesday.clinician_availability_key])
            )
          end
        end

        context "when booking at 11am on Saturday" do
          before do
            travel_to Time.new(2021, 12, 4, 11, 0, 0, "utc") # Saturday 11am
          end

          let!(:availability_tuesday) do
             create(
               :clinician_availability,
              appointment_start_time: 3.days.from_now + 1.hour,
              appointment_end_time: 3.days.from_now + 2.hours
             )
          end

          it "first availability will be 9am Wednesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_tuesday.facility_id, availability_tuesday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_tuesday.clinician_availability_key])
            )
          end
        end

        context "when booking at 11am on Sunday" do
          before do
            travel_to Time.new(2021, 12, 5, 11, 0, 0, "utc") # Sunday 11am
          end

          let!(:availability_tuesday) do
            create(
              :clinician_availability,
              appointment_start_time: 2.days.from_now + 1.hour,
              appointment_end_time: 2.days.from_now + 2.hours
            )
          end
        
          it "first availability will be 9am Wednesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_tuesday.facility_id, availability_tuesday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_tuesday.clinician_availability_key])
            )
          end    
        end

        context "when booking at 11am on Monday" do
          before do
            travel_to Time.new(2021, 12, 6, 11, 0, 0, "utc") # Monday 11am
          end

          let!(:availability_early_wednesday) do
            create(
              :clinician_availability,
              appointment_start_time: 2.days.from_now - 1.hour,
              appointment_end_time: 2.days.from_now
            )
          end

          let!(:availability_late_wednesday) do
            create(
              :clinician_availability,
              appointment_start_time: 2.days.from_now + 1.hour,
              appointment_end_time: 2.days.from_now + 2.hours
            )
          end
        
          it "first availability will be 11am Wednesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_early_wednesday.facility_id, availability_early_wednesday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_late_wednesday.clinician_availability_key])
            )
          end
  
        end
      end

      context "when given 96 hours" do
        let(:block_out_hours) { 96 }
        let(:office_key) { '995456' }

        context "when booking at 11am on Wednesday" do
          before do
            travel_to Time.new(2021, 12, 1, 11, 0, 0, "utc") # Monday 11am
          end

          let!(:availability_monday) do
            create(
              :clinician_availability,
              appointment_start_time: 5.days.from_now + 1.hour,
              appointment_end_time: 5.days.from_now + 2.hours
            )
          end

          let!(:availability_tuesday) do
            create(
              :clinician_availability,
              appointment_start_time: 6.days.from_now + 1.hour,
              appointment_end_time: 6.days.from_now + 2.hours
            )
          end
        
          it "first availability will be 11am Wednesday" do
            expect(ClinicianAvailability.active_data(block_out_hours, office_key, availability_monday.facility_id, availability_monday.type_of_care).map(&:clinician_availability_key)).to(
              match_array([availability_tuesday.clinician_availability_key])
            )
          end
        end
      end

      context "when appointment exists" do
        let!(:stub_time) { Time.now.utc } # Current Time, as exclusion logic always checks for appointment greater than current date.

        it "Exclude from clinician availability list, if a patient_appointment exists for a clinician_availability_key" do
          clinician_availability_after_2_day = create(:clinician_availability, appointment_start_time: 2.day.from_now + 2.hours,
                                                      appointment_end_time: 2.day.from_now + 3.hours)
          clinician_availability_after_3_day = create(:clinician_availability, appointment_start_time: 3.day.from_now + 2.hours,
                                                      appointment_end_time: 3.day.from_now + 3.hours)
          clinician_availability_after_4_day = create(:clinician_availability, appointment_start_time: 4.day.from_now + 2.hours,
                                                      appointment_end_time: 4.day.from_now + 3.hours)
          clinician_availability_after_5_day = create(:clinician_availability, appointment_start_time: 5.day.from_now + 2.hours,
                                                      appointment_end_time: 5.day.from_now + 3.hours)

          create(:clinician_availability_status, clinician_availability_key: clinician_availability_after_2_day.clinician_availability_key, available_date: clinician_availability_after_2_day.appointment_start_time)
          create(:clinician_availability_status, clinician_availability_key: clinician_availability_after_3_day.clinician_availability_key, available_date: clinician_availability_after_3_day.appointment_start_time)
          create(:clinician_availability_status, clinician_availability_key: clinician_availability_after_4_day.clinician_availability_key, available_date: clinician_availability_after_4_day.appointment_start_time)
          create(:clinician_availability_status, clinician_availability_key: clinician_availability_after_5_day.clinician_availability_key, available_date: clinician_availability_after_5_day.appointment_start_time)

          expect(ClinicianAvailability.active_data(48, clinician_availability_after_4_day.license_key, clinician_availability_after_4_day.facility_id, clinician_availability_after_4_day.type_of_care).map(&:clinician_availability_key).size).to eq(0)

          clinician_availability_after_6_day = create(:clinician_availability, appointment_start_time: 6.day.from_now + 2.hours,
                                                      appointment_end_time: 6.day.from_now + 3.hours)
          create(:clinician_availability_status, clinician_availability_key: clinician_availability_after_6_day.clinician_availability_key, available_date: clinician_availability_after_6_day.appointment_start_time)

          expect(ClinicianAvailability.active_data(48, clinician_availability_after_6_day.license_key, clinician_availability_after_6_day.facility_id, clinician_availability_after_6_day.type_of_care).map(&:clinician_availability_key).size).to eq(0)
        end
      end
    end

    describe ".before time appointment data" do
      it "filters clinician_availabilities by before_time data return availabilities before filter hour" do
        availability_after_24_hours = create(:clinician_availability,
                                             appointment_start_time: 1.day.from_now, appointment_end_time: 3.hours.from_now + 1.day)

        _availability_within_24_hours = create(:clinician_availability, appointment_start_time: 6.hours.from_now,
                                                                        appointment_end_time: 7.hours.from_now)

        expect(ClinicianAvailability.before_time_appointment_availability(Time.zone.local(Time.zone.now.year, Time.zone.now.month,
                                                                                          Time.zone.now.day, 10, 0, 0).utc + 3.days)
                                                                                          .map(&:clinician_availability_key))
          .to match_array([availability_after_24_hours.clinician_availability_key])
      end

      it "filters clinician_availabilities by before_time data does not include availabilities within 24 hours" do
        _availability_after_24_hours = create(:clinician_availability,
                                              appointment_start_time: 2.hours.from_now + 1.day, appointment_end_time: 3.hours.from_now + 1.day)

        availability_within_24_hours = create(:clinician_availability, appointment_start_time: 6.hours.from_now,
                                                                       appointment_end_time: 7.hours.from_now)
        expect(ClinicianAvailability.before_time_appointment_availability(5.hours.from_now).size).to be < ClinicianAvailability.count
        expect(ClinicianAvailability.before_time_appointment_availability(Time.now.utc + 5.hours + 2.days).map(&:clinician_availability_key))
          .not_to include(availability_within_24_hours.clinician_availability_key)
      end
    end

    describe ".after time appointment data" do
      it "filters clinician_availabilities by after time data" do
        availability_after_24_hours = create(:clinician_availability,
                                             appointment_start_time: Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 16, 0,
                                                                                     0).utc + 1.day,
                                             appointment_end_time: 5.hours.from_now + 1.day)

        _clinician_availabilitiy2 = create(:clinician_availability, appointment_start_time: 2.hours.from_now,
                                                                    appointment_end_time: 3.hours.from_now)
        expect(ClinicianAvailability.after_time_appointment_availability(4.hours.from_now).size).to be < ClinicianAvailability.count

        availabilities = ClinicianAvailability.after_time_appointment_availability(Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 15,
                                                                                                   0, 0).utc + 2.days)
        expect(availabilities.map(&:clinician_availability_key))
          .to include(availability_after_24_hours.clinician_availability_key)
      end
    end

    describe ".facility_id data" do
      it "filters clinician_availabilities by facility id" do
        clinician_availability1 = create(:clinician_availability, appointment_start_time: 2.hours.from_now,
                                                                  appointment_end_time: 3.hours.from_now, facility_id: 1)
        _clinician_availability2 = create(:clinician_availability, appointment_start_time: Time.zone.now,
                                                                   appointment_end_time: 3.hours.from_now, facility_id: 2)

        expect(ClinicianAvailability.with_facility_id(1).size).to be < ClinicianAvailability.count
        expect(ClinicianAvailability.with_facility_id(1).map(&:clinician_availability_key)).to match_array([clinician_availability1.clinician_availability_key])
      end
    end

    describe ".clinician_id data" do
      it "filters clinician_availabilities by clinician_id" do
        clinician1 = create(:clinician)
        clinician2 = create(:clinician)
        clinician_availability1 = create(:clinician_availability, appointment_start_time: 2.hours.from_now,
                                                                  appointment_end_time: 3.hours.from_now, license_key: 9452, provider_id: 1, facility_id: 1)
        _clinician_availability2 = create(:clinician_availability, appointment_start_time: Time.zone.now,
                                                                   appointment_end_time: 3.hours.from_now, license_key: 9452, provider_id: 1, facility_id: 2)
        _clinician_address1  = create(:clinician_address, office_key: 9452, provider_id: 1, facility_id: 1,
                                                          clinician_id: clinician1.id)
        _clinician_address2  = create(:clinician_address, office_key: 9452, provider_id: 1, facility_id: 2,
                                                          clinician_id: clinician2.id)

        expect(ClinicianAvailability.with_clinician_id(clinician1.id).size).to be < ClinicianAvailability.count
        expect(ClinicianAvailability.with_clinician_id(clinician1.id).map(&:clinician_availability_key))
          .to match_array([clinician_availability1.clinician_availability_key])
      end
    end

    describe ".zip_codes data" do
      it "filters clinician_availabilities by zip_codes" do
        _clinician_address1  = create(:clinician_address, office_key: 9452, provider_id: 1, facility_id: 1,
                                                          postal_code: "30301")
        _clinician_address2  = create(:clinician_address, office_key: 9452, provider_id: 1, facility_id: 2,
                                                          postal_code: "30302")
        clinician_availability1 = create(:clinician_availability, license_key: 9452, provider_id: 1, facility_id: 1)
        _clinician_availability2 = create(:clinician_availability, license_key: 9452, provider_id: 1, facility_id: 2)

        expect(ClinicianAvailability.with_zip_codes("30301").size).to be < ClinicianAvailability.count
        expect(ClinicianAvailability.with_zip_codes("30301")).to match_array([clinician_availability1])
      end
    end

    describe ".duration method" do
      it "returns hour" do
        clinician_availabilitiy = create(:clinician_availability, appointment_start_time: 2.hours.from_now,
                                                                  appointment_end_time: 3.hours.from_now, license_key: 9452, provider_id: 1, facility_id: 1)

        expect(clinician_availabilitiy.duration).to eq(60)
      end
    end

    describe "availability by time" do
      let(:availability) { create(:clinician_availability, license_key: 9452, provider_id: 1, facility_id: 1) }
      context "availabilities_before_time" do
        it "returns availabilities before the provided time" do
          date = DateTime.now.utc.change({ hour: 10, min: 30 })
          availability.update(appointment_start_time: DateTime.now.utc.change({ hour: 10, min: 20, day: date.day + 1 }))

          expect(ClinicianAvailability.availabilities_before_time(date).map(&:clinician_availability_key)).to include(availability.clinician_availability_key)
        end

        it "should not returns availabilities before the provided time" do
          date = DateTime.now.utc.change({ hour: 10, min: 30 })
          availability.update(appointment_start_time: DateTime.now.utc.change({ hour: 11, min: 0o0,
                                                                                day: date.day + 1 }))

          expect(ClinicianAvailability.availabilities_before_time(date)).to be_empty
        end
      end

      context "availabilities_after_time" do
        it "returns availabilities after the provided time" do
          date = DateTime.now.utc.change({ hour: 10, min: 0 })
          availability.update(appointment_start_time: DateTime.now.utc.change({ hour: 11, min: 30, day: date.day + 1 }))

          expect(ClinicianAvailability.availabilities_after_time(date).map(&:clinician_availability_key)).to include(availability.clinician_availability_key)
        end

        it "returns empty relation when no availabilities present after selected time" do
          date = DateTime.now.utc.change({ hour: 10, min: 0 })
          availability.update(appointment_start_time: DateTime.now.utc.change({ hour: 9, min: 30, day: date.day + 1 }))

          expect(ClinicianAvailability.availabilities_after_time(date)).to be_empty
        end
      end

      describe "with_in_office_availabilities" do
        let!(:address) { create(:clinician_address) }
        let!(:availability) do
          create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                          provider_id: address.provider_id)
        end
        let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
        let(:availability2) do
          create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729)
        end

        it "should return addresses with in_office availabilities" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

          expect(ClinicianAvailability.with_in_office_availabilities.count).to eq(1)
          expect(ClinicianAvailability.with_in_office_availabilities.first.clinician_availability_key).to eq(availability.clinician_availability_key)
        end
      end

      describe "with_virtual_visit_availabilities" do
        let!(:address) { create(:clinician_address) }
        let!(:availability) do
          create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                          provider_id: address.provider_id)
        end
        let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
        let(:availability2) do
          create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729)
        end

        it "should return addresses with video_visit availabilities" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

          expect(ClinicianAvailability.with_virtual_visit_availabilities.count).to eq(1)
          expect(ClinicianAvailability.with_virtual_visit_availabilities.first.clinician_availability_key).to eq(availability2.clinician_availability_key)
        end
        it "should return clinician tele_color" do
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 0)

          expect(ClinicianAvailability.with_virtual_visit_availabilities.first).to have_attributes('tele_color':"ORANGE" )
        end
        it "should return clinician in_person_color" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)

          expect(ClinicianAvailability.with_in_office_availabilities.first).to have_attributes('in_person_color':"BLUE" )
        end
      end

      describe "with_modality_availabilities" do
        let!(:address) { create(:clinician_address) }
        let!(:availability) do
          create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                          provider_id: address.provider_id)
        end
        let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
        let!(:availability2) do
          create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729)
        end

        it "should return addresses with both virtual and in office supported modalities" do
          availability.update(in_person_visit: 1, virtual_or_video_visit: 0)
          availability2.update(virtual_or_video_visit: 1, in_person_visit: 1)

          expect(ClinicianAvailability.with_modality_availabilities.count).to eq(2)
          expect(ClinicianAvailability.with_modality_availabilities.last.clinician_availability_key).to eq(availability2.clinician_availability_key)
        end
      end

      describe "patient_clinician_availabilities" do
        let!(:address) { create(:clinician_address) }
        let!(:existing_patient_availability) do
          create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
                                          provider_id: address.provider_id, reason: "TELE", is_ia: 0, is_fu: 1)
        end
        let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
        let!(:availability) do
          create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729, is_ia: 1, is_fu: 0)
        end

        it "should return availabilities for new patient" do
          expect(ClinicianAvailability.new_patient_clinician_availabilities.count).to eq(1)
          expect(ClinicianAvailability.new_patient_clinician_availabilities.first.clinician_availability_key)
            .to eq(availability.clinician_availability_key)
        end

        it "should return availabilities for existing patient" do
          expect(ClinicianAvailability.existing_patient_clinician_availabilities.count).to eq(1)
          expect(ClinicianAvailability.existing_patient_clinician_availabilities.first.clinician_availability_key)
            .to eq(existing_patient_availability.clinician_availability_key)
        end
      end

      describe ".with_active_office_keys" do
        it "returns clinician addresses with active license key" do
          license_key   = create(:license_key)
          availability1 = create(:clinician_availability, license_key: license_key.key)

          expect(ClinicianAvailability.with_active_office_keys.map(&:clinician_availability_key)).to include(availability1.clinician_availability_key)

          LicenseKey.find_by(key: availability1.license_key).update(active: false)
          expect(ClinicianAvailability.with_active_office_keys.map(&:clinician_availability_key)).to_not include(availability1.clinician_availability_key)
        end
      end

      describe " with facility_ids" do
        it "returns clinician availabilities with selected facility ids only" do
          license_key   = create(:license_key)
          facility1 = create(:facility_accepted_insurance)
          facility2 = create(:facility_accepted_insurance)
          facility3 = create(:facility_accepted_insurance)

          availability1 = create(:clinician_availability, license_key: license_key.key, facility_id: facility1.id)
          availability2 = create(:clinician_availability, facility_id: facility2.id)

          facility_ids = [facility2.id, facility3.id]

          expect(ClinicianAvailability.with_facility_ids(facility_ids)).to include(availability2)
          expect(ClinicianAvailability.with_facility_ids(facility_ids)).not_to include(availability1)

          LicenseKey.find_by(key: availability1.license_key).update(active: false)
          expect(ClinicianAvailability.with_active_office_keys.map(&:clinician_availability_key)).to_not include(availability1.clinician_availability_key)
        end
      end

      describe " with video" do
        it "returns clinician availabilities with video visits only" do
          license_key   = create(:license_key)
          facility1 = create(:facility_accepted_insurance)

          availability1 = create(:clinician_availability, license_key: license_key.key, facility_id: facility1.id, virtual_or_video_visit: true)
          availability2 = create(:clinician_availability, facility_id: facility1.id, virtual_or_video_visit: false)


          expect(ClinicianAvailability.with_virtual_visit_availabilities).to include(availability1)
          expect(ClinicianAvailability.with_virtual_visit_availabilities).not_to include(availability2)

          LicenseKey.find_by(key: availability1.license_key).update(active: false)
          expect(ClinicianAvailability.with_active_office_keys.map(&:clinician_availability_key)).to_not include(availability1.clinician_availability_key)
        end
      end
    end
  end

  describe ".filter_by_availability_time" do
    let!(:ca_2pm) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 5.hours) }
    let!(:ca_5pm) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 8.hours) }
    let!(:ca_7pm) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 10.hours) }
    let!(:ca_9pm) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 12.hours) }
    let!(:ca_12am) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 15.hours) }

    context "with positive offset" do
      let(:offset) { 480 }

      context "when filtering before_10_AM" do
        let(:filters) { ["before_10_AM"] }
        subject { ClinicianAvailability.filter_by_availability_time(filters, offset) }

        it "returns availabilities between before_10_AM" do
          expect(subject).to eq([ca_2pm, ca_5pm])
        end
      end

      context "when filtering before_12_PM" do
        let(:filters) { ["before_12_PM"] }
        subject { ClinicianAvailability.filter_by_availability_time(filters, offset) }

        it "returns availabilities between before_12_PM" do
          expect(subject).to eq([ca_2pm, ca_5pm, ca_7pm])
        end
      end
    end

    context "with negative offset" do
      let!(:ca_9am) { create(:clinician_availability, appointment_start_time: 2.days.from_now) }
      let!(:ca_11am) { create(:clinician_availability, appointment_start_time: 2.days.from_now + 2.hours) }
      let(:offset) { -60 }

      context "when filtering before_10_AM" do
        let(:filters) { ["before_10_AM"] }
        subject { ClinicianAvailability.filter_by_availability_time(filters, offset) }

        it "returns availabilities between before_10_AM" do
          expect(subject).to eq([ca_12am, ca_9am])
        end
      end

      context "when filtering before_12_PM" do
        let(:filters) { ["before_12_PM"] }
        subject { ClinicianAvailability.filter_by_availability_time(filters, offset) }

        it "returns availabilities between before_12_PM" do
          expect(subject).to eq([ca_12am, ca_9am, ca_11am])
        end
      end

    end

  end
end
