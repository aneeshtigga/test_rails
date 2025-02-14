namespace :feature_enablements do
  desc 'create(states) records in feature_enablements'
  task upload_states: :environment do
    count = 0
    states = %w[AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND
                OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY]

    states.each do |state|
      FeatureEnablement.create!(state: state)
      count += 1
    end

    puts "#{count} states created in feature_enablements"
  end
end