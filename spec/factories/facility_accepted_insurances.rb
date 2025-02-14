FactoryBot.define do
  factory :facility_accepted_insurance do
    insurance
    clinician
    clinician_address
    supervisors_name {"Esteban Rossi"}
    license_number {"051319"}
  end
end