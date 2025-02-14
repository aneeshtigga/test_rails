FactoryBot.define do
  factory :support_directory do
    cbo { 149330 }
    license_key { 995456 }
    intake_call_in_number { "(925) 212-1778" }
    location { "PCPA-California" }
    support_hours { "8:30am-5:30pm" }
    established_patients_call_in_number { "415-296-5290" }
    follow_up_url { "https://patientportal.advancedmd.com/995456/account/logon" }
  end
end
