FactoryBot.define do
  factory :gender_identity do
    gi            { 'Male' }
    amd_gi        { 'Male' }
    amd_gi_ident  { 558 }
  end

  trait :male do
    gi            { 'Male' }
    amd_gi        { 'Man' }
    amd_gi_ident  { 558 }
  end


  trait :female do
    gi            { 'Female' }
    amd_gi        { 'Woman' }
    amd_gi_ident  { 559 }
  end


  trait :neither do
    gi            { 'Rock' }
    amd_gi        { 'Rubble' }
    amd_gi_ident  { 563 }
  end
end