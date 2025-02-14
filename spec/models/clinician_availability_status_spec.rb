require 'rails_helper'

RSpec.describe ClinicianAvailabilityStatus, type: :model do
  let!(:clinician_availability_status) { create(:clinician_availability_status, status: 0) }
  let!(:clinician_availability_status) { create(:clinician_availability_status, status: 0) }
  let!(:clinician_availability_status) { create(:clinician_availability_status, status: 1) }

  let!(:clinician_availability_status) { create(:clinician_availability_status, available_date: Time.now.utc+4.days, status: 0) }
  let!(:clinician_availability_status) { create(:clinician_availability_status, available_date: Time.now.utc+4.days, status: 0) }
  let!(:clinician_availability_status) { create(:clinician_availability_status, available_date: Time.now.utc+4.days, status: 1) }
  let!(:clinician_availability_status) { create(:clinician_availability_status, available_date: Time.now.utc+5.days, status: 1) }

  describe 'enum values to be in_progress & scheduled' do
    it { should define_enum_for(:status).with_values([:in_progress, :scheduled]) }
  end

  describe 'default scope' do
    it 'returns clinician availability with status of scheduled only' do
      expect(ClinicianAvailabilityStatus.pluck(:status)).to be_an_instance_of(Array)
      expect(ClinicianAvailabilityStatus.pluck(:status)).to match_array(['scheduled'])
    end
  end
end
