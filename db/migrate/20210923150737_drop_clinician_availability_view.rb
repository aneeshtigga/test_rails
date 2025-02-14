class DropClinicianAvailabilityView < ActiveRecord::Migration[6.1]
  def change
    execute(
      <<-QUERY
        DROP MATERIALIZED VIEW IF EXISTS mv_clinician_availability;
        DROP INDEX IF EXISTS mv_clinician_availability_idx;
      QUERY
    )
  end
end
