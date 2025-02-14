require 'rails_helper'

RSpec.describe HolidaySchedule, type: :model do
  describe "validations" do
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:date) }
  end
end
