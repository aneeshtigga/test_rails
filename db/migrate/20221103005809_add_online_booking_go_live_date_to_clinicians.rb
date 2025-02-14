class AddOnlineBookingGoLiveDateToClinicians < ActiveRecord::Migration[6.1]
  def change
    add_column :clinicians, :online_booking_go_live_date, :datetime
  end
end
