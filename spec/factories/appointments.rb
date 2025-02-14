FactoryBot.define do
  factory :appointment do
    clinician
    clinician_address
    modality { 0 }
    start_time { DateTime.new(2021,7,27,16,0,0) }
    end_time { DateTime.new(2021,7,27,16,30,0) }
    type_of_care { "Adult Therapy"}
    reason { "IA" }
    sequence(:clinician_availability_key)
  end

  trait :with_patient do
    after(:create) do |appointment|
      create(:patient_appointment, appointment: appointment)
    end
  end

end
