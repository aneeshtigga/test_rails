# db/migrate/20230330105145_add_index_for_state_to_clinician_addresses.rb

# Recently added an "entire_state" query to the ClinicianSearch
# service class.

class AddIndexForStateToClinicianAddresses < ActiveRecord::Migration[6.1]
  def change
    add_index   :clinician_addresses, :state, unique: false
  end
end
