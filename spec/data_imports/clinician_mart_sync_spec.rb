require "rails_helper"

RSpec.describe ClinicianMartSync do
  describe ".import_data" do
    describe "time_since is specified" do
      it "imports clinician records updated after time since" do
        recently_updated_clinician = create(:clinician_mart, load_date: Time.now.utc)
        _not_recently_updated_clinician = create(:clinician_mart, load_date: Time.now.utc - 3.days)

        ClinicianMartSync.import_data(time_since: Time.zone.now - 1.day)
        ClinicianUpdaterWorker.drain

        expect(Clinician.all.size).to eq(1)
        expect(Clinician.last).to have_attributes(
          provider_id: recently_updated_clinician.clinician_id
        )
      end
    end

    describe "clinician mart count" do
      it "returns clinicians add_update attempted count" do
        create(:clinician_mart, load_date: Time.now.utc)

        import_data = ClinicianMartSync.import_data(time_since: Time.zone.now - 1.day)
        ClinicianUpdaterWorker.drain

        expect(import_data[:clinicians_add_update_attempted_count]).to eq(1)
        expect(import_data.keys).to eq([:clinicians_count, :clinicians_add_update_attempted_count, :created_languages, :created_license_types] )
      end
    end

    describe "time_since is not specified" do
      it "imports all clinician records" do
        _recently_updated_clinician = create(:clinician_mart, load_date: Time.zone.now)
        _not_recently_updated_clinician = create(:clinician_mart, load_date: Time.zone.now - 3.days)

        ClinicianMartSync.import_data(time_since: nil)
        ClinicianUpdaterWorker.drain

        expect(Clinician.all.size).to eq(2)
      end

      it "imports cbo data of clinician" do
        clinician_mart_with_cbo = create(:clinician_mart, cbo: "130000" )
        Sidekiq::Testing.inline! do
          ClinicianMartSync.import_data(time_since: nil)

          expect(Clinician.count).to eq(1)
          expect(Clinician.first.cbo).to eq(clinician_mart_with_cbo.cbo)
        end
      end
    end

    describe "existing clinician no longer exists in ClinicianMart" do
      let(:active_provider_id) { 123 }
      let(:inactive_provider_id) { 321 }

      let!(:active_clinician_mart) do
        create(:clinician_mart,
               clinician_id: active_provider_id)
      end

      let!(:inactive_clinician_mart) do
        create(:clinician_mart,
               :inactive,
               clinician_id: inactive_provider_id)
      end
      let!(:active_clinician) do
        create(:clinician,
               provider_id: active_provider_id)
      end
      let!(:to_be_inactive_clinician) do
        create(:clinician,
               provider_id: inactive_provider_id)
      end

      it "soft-deletes the clinicians" do
        Sidekiq::Testing.inline! do
          ClinicianMartSync.import_data

          expect(Clinician.active.count).to eq(1)
          expect(Clinician.active).to match_array([active_clinician])
        end
      end
    end
  end
end
