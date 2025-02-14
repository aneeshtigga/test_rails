require "rails_helper"
  
RSpec.describe ClinicianUpdater do
  let!(:license_type_1) { create(:license_type, name: "MD") }
  let!(:license_type_2) { create(:license_type, name: "MS") }
  let!(:expertise_1) { create(:expertise, name: "Depression") }
  let!(:expertise_2) { create(:expertise, name: "Eating Disorder") }
  let!(:language_1) { create(:language, name: "English") }
  let!(:language_2) { create(:language, name: "Spanish") }
  describe ".add_or_update_clinician" do
    describe "clinician doesn't exist" do
      let(:languages) { "English, Spanish" }
      let(:expertise) { "Depression, Eating Disorder" }
      let(:provider_id) { 1000 }
      let(:license_key) { 124220 }
      let!(:clinician_mart) do
        create(:clinician_mart,
               clinician_id: provider_id,
               license_key: license_key,
               languages: languages,
               expertise: expertise)
      end

      it "creates a new clinician" do
        ClinicianUpdater.add_or_update_clinician(provider_id: provider_id,license_key: license_key)

        expect(Clinician.last).to have_attributes(
          first_name: clinician_mart.first_name,
          last_name: clinician_mart.last_name,
          middle_name: clinician_mart.middle_name,
          clinician_type: clinician_mart.clinician_type,
          license_type: clinician_mart.license_type,
          about_the_provider: clinician_mart.about_the_provider,
          in_office: clinician_mart.in_office,
          video_visit: clinician_mart.virtual_visit,
          manages_medication: clinician_mart.manages_medication,
          ages_accepted: clinician_mart.ages_accepted,
          provider_id: clinician_mart.clinician_id,
          npi: clinician_mart.npi.to_s,
          telehealth_url: clinician_mart.telehealth_url,
          gender: clinician_mart.gender,
          pronouns: clinician_mart.pronouns,
          license_key: license_key
        )
      end

      it "raises exception on failure" do
        expect{
          ClinicianUpdater.add_or_update_clinician(provider_id: nil,license_key: license_key)
        }.to raise_exception(/clinician/)
      end

      describe "Languages" do
        context "clinician mart languages is present" do
          let(:languages) { "English, Spanish" }

          it "creates clinician languages" do
            ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

            expect(Clinician.last.languages.map(&:name)).to match_array(%w[English Spanish])
          end
        end

        context "clinician mart languages is empty" do
          let(:languages) { "" }

          it "does not create any clinician languages" do
            ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

            expect(Clinician.last.languages.map(&:name)).to eq([])
          end
        end
      end

      describe "Expertises" do
        context "clinician mart expertise is present" do
          let(:expertise) { "Depression, Eating Disorder" }

          it "creates clinician expertises" do
            ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

            expect(Clinician.last.expertises.map(&:name)).to match_array(["Depression", "Eating Disorder"])
          end
        end

        context "clinician mart expertise is empty" do
          let(:expertise) { "" }

          it "does not create any clinician expertises" do
            ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

            expect(Clinician.last.expertises.map(&:name)).to eq([])
          end
        end
      end
    end

    describe "there's an existing clinician" do
      let(:provider_id) { 123 }
      let(:npi) { 321 }
      let(:facility_id) { 1000 }
      let(:license_key) { 124112 }
      let!(:clinician_mart) do
        create(:clinician_mart,
               clinician_id: provider_id,
               npi: npi,
               languages: "English",
               expertise: "Depression",
               location: "updated location",
               facility_id: facility_id,
               first_name: "Jack",
               last_name: "Sparrow",
               license_key: license_key)
      end
      let!(:clinician_to_update) do
        create(:clinician,
               provider_id: provider_id,
               license_key: license_key,
               npi: npi,
               first_name: "Captain",
               last_name: "Blackbeard")
      end

      it "updates existing clinician" do
        ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

        expect(clinician_to_update.reload).to have_attributes(
          first_name: "Jack",
          last_name: "Sparrow"
        )
      end

      it "sets clinician deleted_at flag" do
        clinician_mart.update!(is_active: 0)

        ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

        expect(clinician_to_update.reload.deleted?).to eq(true)
      end

      context "pre-existing languages" do
        let(:language) { create(:language, name: "Spanish") }
        let!(:clinician_language) { create(:clinician_language, clinician: clinician_to_update, language: language) }

        it "removes previous languages" do
          ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

          expect(clinician_to_update.languages.last.name).to eq("English")
          expect(clinician_to_update.clinician_languages.count).to eq(1)
        end
      end

      context "pre-existing expertises" do
        let(:expertise) { create(:expertise, name: "Anxiety") }
        let!(:clinician_expertise) do
          create(:clinician_expertise,
                 clinician: clinician_to_update,
                 expertise: expertise)
        end

        it "removes previous expertises" do
          ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

          expect(clinician_to_update.expertises.last.name).to eq("Depression")
          expect(clinician_to_update.clinician_expertises.count).to eq(1)
        end
      end

      context "pre-existing license types" do
        let!(:license_type) { create(:license_type, name: "MD") }
        let!(:license_type_2) { create(:license_type, name: "MS") }
        let!(:clinician_license_type) do
          create(:clinician_license_type,
                clinician: clinician_to_update,
                license_type: license_type)
        end

        it "updates license types" do
          ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)

          expect(clinician_to_update.clinician_license_types.last.license_type.name).to eq("MD")
          expect(clinician_to_update.clinician_license_types.count).to eq(1)
        end
      end
    end
  end
end
