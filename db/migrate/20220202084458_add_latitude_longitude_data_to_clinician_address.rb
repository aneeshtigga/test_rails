class AddLatitudeLongitudeDataToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    count = 0
    ClinicianAddress.all.each do |clinician_address|
      count += 0.1
      ## As radar api has 10 request per second limitation we need to call sidekiq job at different time
      ClinicianAddressCoordinateWorker.perform_at(count.seconds.from_now, clinician_address.id)
    end
  end
end
