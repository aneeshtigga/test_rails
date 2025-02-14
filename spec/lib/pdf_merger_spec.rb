require "rails_helper"

RSpec.describe PdfMerger do
  describe ".merge" do
    let(:pdf1) { File.read(Rails.root.join("spec", "fixtures", "test1.pdf")) }
    let(:pdf2) { File.read(Rails.root.join("spec", "fixtures", "test2.pdf")) }

    it "merges the pdfs into one file" do
      pdfs = [pdf1, pdf2]
      output = PdfMerger.merge(pdfs)

      expect(output.length).not_to be_zero
    end
  end
end