class AddDataToClinicianAcceptedAge < ActiveRecord::Migration[6.1]
  def change
    Clinician.all.each do |clinician|
      clinician.save! #update clinician accepted ages table
    end
  end
end
