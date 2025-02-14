class CreateClinicianAvailabilityView < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute(
          <<-QUERY
            CREATE MATERIALIZED VIEW mv_clinician_availability AS
              SELECT *
              FROM clinician_availability
              ORDER BY rank_most_available, rank_soonest_available ASC
            WITH DATA;

            CREATE UNIQUE INDEX mv_clinician_availability_idx ON mv_clinician_availability(clinician_availability_key);
          QUERY
        )
      end

      dir.down do
        execute(
          <<-QUERY
            DROP MATERIALIZED VIEW IF EXISTS mv_clinician_availability;
            DROP mv_clinician_availability_idx IF EXISTS mv_clinician_availability_idx;
          QUERY
        )
      end
    end
  end
end
