FactoryBot.define do
  factory :clinician_intervention_focus_areas, class: InterventionsMart do
    focus_area_name {'Mindfulness'}
    focus_area_type {'intervention'}
    is_active {1}
    load_date {Time.now.utc}
  end

  factory :clinician_population_focus_areas, class: PopulationsMart do
    focus_area_name {'First Responders'}
    focus_area_type {'population'}
    is_active {1}
    load_date {Time.now.utc}
  end
end