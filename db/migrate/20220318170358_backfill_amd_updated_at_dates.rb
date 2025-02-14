class BackfillAmdUpdatedAtDates < ActiveRecord::Migration[6.1]
  def change
    Patient.where(amd_updated_at: nil).update_all("amd_updated_at = created_at")
    ResponsibleParty.where(amd_updated_at: nil).update_all("amd_updated_at = created_at")
  end
end
