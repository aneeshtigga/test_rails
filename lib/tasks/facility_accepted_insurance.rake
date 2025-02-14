namespace :facility_accepted_insurance do
  desc "FAI"
  task sync_with_redshift: :environment do
    include Tasks::Colorize

    dry_run = ENV["dry_run"].present?

    untouched = 0
    touched = []

    puts green("Start Time #{Time.zone.now}")
    puts yellow("Dry Run: #{dry_run}") if dry_run

    records = FacilityAcceptedInsurance.order(id: :desc).all
    bar = RakeProgressBar.new(records.size)

    records.each do |fai|
      insurance = Insurance.unscoped.find(fai.insurance_id)
      clinician_id = Clinician.unscoped.find(fai.clinician_id)&.provider_id
    
      insurance_data = {
        carrier_name: insurance[:mds_carrier_name],
        mds_carrier_name: insurance[:mds_carrier_name],
        amd_carrier_id: insurance[:amd_carrier_id],
        amd_carrier_name: insurance[:amd_carrier_name],
        amd_carrier_code: insurance[:amd_carrier_code],
        license_key: insurance[:license_key],
        amd_is_active: insurance[:amd_is_active],
        clinician_id: clinician_id
      }

      if CarrierInsurance.where(insurance_data).first
        untouched += 1
      else
        touched << fai.id
        # if dry_run is true, don't save the record
        fai.update(active: false) unless dry_run

        # write to log file in log/facility_accepted_insurance.log
        File.write(Rails.root.join("log", "facility_accepted_insurance.log"), "FAI #{fai.id} deactivated\n", mode: "a")
      end
      bar.inc

    end.nil?
    bar.finished

    puts green("Total untouched: #{untouched}")
    puts red("Total deactivated: " + touched.to_s)

    puts green("End Time #{Time.zone.now}")
    puts yellow("No records were changed because this was a dry run.") if dry_run
  end
end
