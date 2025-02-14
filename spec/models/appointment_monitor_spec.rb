require "rails_helper"

RSpec.describe AppointmentMonitor, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe ".within_threshold?" do
    describe "it is a weekday during business hours" do
      it "patient appointment was last created within threshold" do
        travel_to Time.zone.local(2022, 11, 24, 16, 00, 00) do
          patient_appt =  create(:patient_appointment)

          expect(AppointmentMonitor.within_threshold?).to be true
        end
      end

      it "patient appointment was last created outside threshold" do
        travel_to Time.zone.local(2022, 11, 24, 16, 00, 00) do
          patient_appt = create(:patient_appointment, created_at: Time.zone.now - 3.hours)

          expect(AppointmentMonitor.within_threshold?).to be false
        end
      end
    end

    describe "it is a weekday during non-business hours" do
      it "patient appointment was last created within threshold" do
        travel_to Time.zone.local(2022, 11, 24, 01, 00, 00) do
          patient_appt =  create(:patient_appointment)

          expect(AppointmentMonitor.within_threshold?).to be true
        end
      end

      it "patient appointment was last created outside threshold" do
        travel_to Time.zone.local(2022, 11, 24, 01, 00, 00) do
          patient_appt = create(:patient_appointment, created_at: Time.zone.now - 6.hours)

          expect(AppointmentMonitor.within_threshold?).to be false
        end
      end
    end

    describe "it is a weekend during business hours" do
      it "patient appointment was last created within threshold" do
        travel_to Time.zone.local(2022, 11, 19, 16, 00, 00) do
          patient_appt =  create(:patient_appointment)

          expect(AppointmentMonitor.within_threshold?).to be true
        end
      end

      it "patient appointment was last created outside threshold" do
        travel_to Time.zone.local(2022, 11, 19, 16, 00, 00) do
          patient_appt = create(:patient_appointment, created_at: Time.zone.now - 12.hours)

          expect(AppointmentMonitor.within_threshold?).to be false
        end
      end
    end

    describe "it is a weekend during non-buisness hours" do
      it "patient appointment was last created within threshold" do
        travel_to Time.zone.local(2022, 11, 19, 01, 00, 00) do
          patient_appt =  create(:patient_appointment)

          expect(AppointmentMonitor.within_threshold?).to be true
        end
      end

      it "patient appointment was last created outside threshold" do
        travel_to Time.zone.local(2022, 11, 19, 01, 00, 00) do
          patient_appt = create(:patient_appointment, created_at: Time.zone.now - 15.hours)

          expect(AppointmentMonitor.within_threshold?).to be false
        end
      end
    end
  end
end
