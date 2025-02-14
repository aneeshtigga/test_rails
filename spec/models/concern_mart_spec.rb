require 'rails_helper'

RSpec.describe ConcernMart, type: :model do
  let!(:concern_mart) { create(:concern_mart) }

  describe 'default_scope' do
    it 'returns only concerns' do
      expect(ConcernMart.all.pluck(:focus_area_type).uniq).to match([concern_mart.focus_area_type])
    end
  end

  describe '#concern_data' do
    it 'return concern data attributes' do
      expect(concern_mart.concern_info).to include(
        focus_area_name: 'Eating concerns',
        focus_area_type: 'concern',
        is_active: true
      )
    end
  end
end
