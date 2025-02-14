class RenameVideoVisitClinicianMart < ActiveRecord::Migration[6.1]
  def change
    rename_column :vw_clinician_mart, :video_visit, :virtual_visit
  end
end
