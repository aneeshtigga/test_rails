class SupervisedClinicianAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :supervised_clinician, :boolean, comment: "Check if clinician is supervised"
    add_column :clinicians, :supervisory_disclosure, :string, comment: "Clinician supervisory disclosure to inform the patient"
    add_column :clinicians, :supervisory_type, :string, comment: "Supervisory type can be billable, clinical or blank"
    add_column :clinicians, :supervising_clinician, :text, comment: "Json will list the supervising clinician(s)"
    add_column :clinicians, :display_supervised_msg, :boolean, comment: "will be used the patient needs to be informed and display
                                                                                                    clinician disclosure message"
  end
end
