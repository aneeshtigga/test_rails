require 'rails_helper'

RSpec.describe InterventionsMart, type: :model do
  let(:subject) { FactoryBot.build(:clinician_intervention_focus_areas) }

  describe 'default_scope' do
    let!(:interventions_mart) { create(:clinician_intervention_focus_areas, focus_area_type: 'intervention') }

    it 'returns only concerns' do
      expect(InterventionsMart.all.pluck(:focus_area_type).uniq).to match([interventions_mart.focus_area_type])
    end
  end

  describe '#intervention_data' do
    it 'return intervention data attributes' do
      expect(subject.intervention_info).to include(
                                        focus_area_name: 'Mindfulness',
                                        focus_area_type: 'intervention',
                                        is_active: true
                                      )
    end
  end
end
