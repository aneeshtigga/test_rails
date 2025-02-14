FactoryBot.define do
  factory :clinician_education do
    universityname { "Bethel University" }
    universitystate { "MN" }
    universitycity { "St. Paul" }
    universitycountry { "United States" }
    referencetype { "Medical Education" }
    degree { "MA" }
    graduationyear { 2005 }
    npi { 1_114_092_384 }
  end
end
