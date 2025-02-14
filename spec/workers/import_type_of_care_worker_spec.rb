require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe ImportTypeOfCareWorker, type: :worker do
  describe "Sidekiq Worker" do
    it "should respond to #perform" do
      expect(ImportTypeOfCareWorker.new).to respond_to(:perform)
    end
  end

  describe "ImportTypeOfCareWorker" do
    it "should enqueue a job" do
      create(:type_of_care_appt_type)
      ImportTypeOfCareWorker.perform_async
      expect(ImportTypeOfCareWorker.jobs.size).to eq(1)
    end

    it "should import data" do
      clinician = create(:clinician)
      create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
      Sidekiq::Testing.inline! do
        ImportTypeOfCareWorker.new.perform
      end
      expect(TypeOfCare.count).to eq(TypeOfCareApptType.count)
      expect(TypeOfCare.first.slice(:amd_license_key,
                                    :type_of_care)).to eq(TypeOfCareApptType.first.slice(:amd_license_key,
                                                                                         :type_of_care))
    end
  end
end
