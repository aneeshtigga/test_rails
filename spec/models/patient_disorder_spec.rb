require 'rails_helper'

RSpec.describe PatientDisorder, type: :model do
  describe "associations" do
    it { should belong_to(:patient) }
    it { should belong_to(:concern).optional }
    it { should belong_to(:population).optional }
    it { should belong_to(:intervention).optional }
  end
end
