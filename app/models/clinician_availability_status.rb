class ClinicianAvailabilityStatus < ApplicationRecord
  enum status: { in_progress: 0, scheduled: 1}

  # adding default scope, because we are not going maintain any other status in this table, other than scheduled status
  default_scope { where(status: :scheduled)}
end
