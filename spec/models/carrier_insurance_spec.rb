require 'rails_helper'

RSpec.describe CarrierInsurance, type: :model do
  describe "inheritance" do
    it { expect(CarrierInsurance).to be < DataWarehouse }
  end
end
