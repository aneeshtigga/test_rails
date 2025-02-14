class ChangeEmergencyContactAssociation < ActiveRecord::Migration[6.1]
  def change
    remove_reference :emergency_contacts, :account_holder, index: true, foreign_key: false
    add_reference    :emergency_contacts, :patient,        index: true, foreign_key: true
  end
end
