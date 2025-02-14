require 'rails_helper'

RSpec.describe ApiRequestResponse, type: :model do
  describe "validations" do
    it { should validate_presence_of(:payload) }
    it { should validate_presence_of(:response) }
  end
end
