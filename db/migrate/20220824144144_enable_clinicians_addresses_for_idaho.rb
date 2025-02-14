class EnableCliniciansAddressesForIdaho < ActiveRecord::Migration[6.1]
  def change
    ClinicianAddress.unscoped.where(:facility_id => 1756).where(:office_key => 148382)&.update(:deleted_at => nil)
  end
end
