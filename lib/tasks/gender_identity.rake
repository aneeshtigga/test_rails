namespace :gender_identity do
  desc "Create gender identities"
  task import: :environment do
    include Tasks::Colorize

    puts yellow("Start Time #{Time.zone.now}")

    if GenderIdentity.find_by(amd_gi_ident: 558)
      puts green("Gender identities exist - no import needed.")
    else
      GenderIdentity.create!(amd_gi_ident: 558, gi: "Male", amd_gi: "Male")
      GenderIdentity.create!(amd_gi_ident: 559, gi: "Female", amd_gi: "Female")
      GenderIdentity.create!(amd_gi_ident: 560, gi: "Transgender Male", amd_gi: "Transgender Male / Trans Man / Female-to-Male")
      GenderIdentity.create!(amd_gi_ident: 561, gi: "Transgender Female", amd_gi: "Transgender Female / Trans Woman / Male-to-Female")
      GenderIdentity.create!(amd_gi_ident: 562, gi: "Genderqueer", amd_gi: "Genderqueer / Neither Exclusively Male nor Female")
      GenderIdentity.create!(amd_gi_ident: 563, gi: "I don't see my gender listed", amd_gi: "Additional Gender Category / Other")
      GenderIdentity.create!(amd_gi_ident: 564, gi: "I prefer not to say", amd_gi: "Decline to Answer")
      puts green("Completed Gender Identity Import.")
    end

    puts yellow("End Time #{Time.zone.now}")
  end

end
