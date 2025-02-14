class AddSelectedSlotOnAccountHolder < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :selected_slot_info, :jsonb, default: {}
  end
end
