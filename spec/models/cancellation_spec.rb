require 'rails_helper'

RSpec.describe Cancellation, type: :model do
  describe "associations" do
    it { should belong_to(:cancellation_reason).class_name('CancellationReason') }
    it { should belong_to(:patient_appointment).class_name('PatientAppointment') }
  end
end
