require "rails_helper"

RSpec.describe SignaturePdfCreator do
  describe "generate_signature_pdf" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }
      let!(:child_patient) { create(:patient) }
      let!(:self_patient) { create(:patient, account_holder_relationship:0) }
      let(:signature) { "test signature" }

      it "returns pdf content for child patient" do
        patient = child_patient
        signature_instance = SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf")
        expect(signature_instance.generate_signature_pdf.valid_encoding?).to be true
      end

      it "returns pdf content for self patient" do
        patient = self_patient
        signature_instance = SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf")
        expect(signature_instance.generate_signature_pdf).to match("PDF")
      end
  end

  describe "get_child_content" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:patient) { create(:patient) }
    let(:signature) { patient.first_name }
    let(:signature_instance) { SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf") }
    
    it "returns the content for child patient" do 
      expect(signature_instance.get_child_content).to include("Name")
      expect(signature_instance.get_child_content).to include("Date of birth")
      expect(signature_instance.get_child_content).to include("Parent/Guardian")
      expect(signature_instance.get_child_content).to include("Relationship to child")
      expect(signature_instance.get_child_content).to include(signature)
    end

    it "returns the content for child patient" do 
      expect(signature_instance.patient_info).to include("Name")
      expect(signature_instance.patient_info).to include("Date of birth")
      expect(signature_instance.account_holder_info).to include("Parent/Guardian")
      expect(signature_instance.account_holder_info).to include("Relationship to child")
      expect(signature_instance.signature_info).to include(signature)
    end
  end

  describe "get_self_content" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:patient) { create(:patient,account_holder_relationship: 0) }
    let(:signature) { patient.first_name }
    let(:signature_instance) { SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf") }
    
    it "returns the content for self patient" do 
      expect(signature_instance.get_self_content).to include("Name")
      expect(signature_instance.get_self_content).to include("Date of birth")
      expect(signature_instance.get_self_content).to include(signature)
    end

    it "returns the content for self patient" do 
      expect(signature_instance.patient_info).to include("Name")
      expect(signature_instance.patient_info).to include("Date of birth")
      expect(signature_instance.signature_info).to include(signature)
    end
  end

  describe ".data for pdf content" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:child_patient) { create(:patient) }
    let!(:self_patient) { create(:patient, account_holder_relationship:0) }
    let(:signature) { "test signature" }

    it "returns patients data" do 
      patient = child_patient
      signature_instance = SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf")
      expect(signature_instance.patient_full_name.downcase).to include(patient.first_name.downcase)
      expect(signature_instance.patient_full_name.downcase).to include(patient.last_name.downcase)
    end

    it "returns account holder data" do
      patient = self_patient
      signature_instance = SignaturePdfCreator.new(signature, patient.id, "patient_#{patient.id}_signature.pdf")
      expect(signature_instance.account_holder_name.downcase).to include(patient.account_holder.last_name.downcase)
      expect(signature_instance.account_holder_name.downcase).to include(patient.account_holder.first_name.downcase)
      expect(signature_instance.relationship_to_child).to eq("self")
    end
  end
end