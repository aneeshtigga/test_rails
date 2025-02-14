FactoryBot.define do
  factory :education do
    university { "Bethel University"}
    state { "St. Paul" }
    city { "MN" }
    country { "United States "}
    reference_type { "Medical Education" }
    graduation_year { 2005 }
    degree { "MA" }
    clinician { nil }
  end
end
