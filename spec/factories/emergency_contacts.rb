FactoryBot.define do
  factory :emergency_contact do
    first_name { "John" }
    last_name { "Doe" }
    phone { "+#{rand(10**10)}" }
    relationship_to_patient { EmergencyContact.relationship_to_patients.values.sample }
    patient
  end
end
