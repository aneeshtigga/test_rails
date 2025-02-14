require 'rails_helper'

RSpec.describe ExpertiseMart, type: :model do
  let(:subject) { FactoryBot.build(:expertise_mart) }

  describe '.default_scope' do
    let!(:expertise_mart) { create(:expertise_mart, focus_area_type: 'expertise') }

    it 'returns only expertises' do
      expect(ExpertiseMart.all.pluck(:focus_area_type).uniq).to match([expertise_mart.focus_area_type])
    end
  end

  describe '#expertise_data' do
    it 'return expertise data attributes' do
      expect(subject.expertise_info).to include(
        focus_area_name: 'Anxiety',
        focus_area_type: 'expertise',
        is_active: true
      )
    end
  end
end
