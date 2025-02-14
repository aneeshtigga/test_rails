FactoryBot.define do
  factory :postal_code do
    zip_code { "99950" }
    city { "KASAAN" }
    state { "AK" }
    country { "KETCHIKAN GATEWAY" }
    country_code { "130" }
    state_code { "02" }
    time_zone { "America/New_York" }
    latitude { 55.815857 }
    longitude { -132.97985 }
    day_light_saving { "Y" }
    zip_codes_by_radius { { '60_mile': ["44141", "44122"] } }
  end
end
