require 'rails_helper'

RSpec.describe PopulationsMart, type: :model do
  let(:subject) { FactoryBot.build(:clinician_population_focus_areas) }

  describe 'default_scope' do
    let!(:populations_mart) { create(:clinician_intervention_focus_areas, focus_area_type: 'population') }

    it 'returns only populations' do
      expect(PopulationsMart.all.pluck(:focus_area_type).uniq).to match([populations_mart.focus_area_type])
    end
  end

  describe '#population_data' do
    it 'return population data attributes' do
      expect(subject.population_info).to include(
                                             focus_area_name: 'First Responders',
                                             focus_area_type: 'population',
                                             is_active: true
                                           )
    end
  end
end
