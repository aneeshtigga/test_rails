class AddBookedByToAccountHolder < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :booked_by, :string, default: "patient"
  end
end
