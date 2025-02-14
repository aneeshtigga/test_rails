require "rails_helper"
RSpec.describe CreateTypeOfCaresWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(CreateTypeOfCaresWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a CreateTypeOfCaresWorker" do
    it "enqueues an CreateTypeOfCaresWorker job" do
      clinician = create(:clinician)
      create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
      CreateTypeOfCaresWorker.perform_async([clinician.id])

      expect(CreateTypeOfCaresWorker.jobs.size).to eq(1)
      expect(CreateTypeOfCaresWorker).to have_enqueued_sidekiq_job([clinician.id])
    end

    it "receive create_data from TypeOfCare" do
      clinician = create(:clinician)
      create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
      Sidekiq::Testing.inline! do
        expect(TypeOfCare).to receive(:create_data).with(clinician.id).and_return({})

        CreateTypeOfCaresWorker.perform_async(clinician.id)
      end
    end

    it "creates education from clinician_education" do
      clinician = create(:clinician)
      create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
      Sidekiq::Testing.inline! do
        CreateTypeOfCaresWorker.perform_async([clinician.id])
        expect(TypeOfCare.count).to eq 1
      end
    end
  end
end
