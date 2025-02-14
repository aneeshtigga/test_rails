require 'rails_helper'

RSpec.describe CancellationReason, type: :model do
  describe "associations" do
    it { should have_many(:cancellation) }
  end
end
