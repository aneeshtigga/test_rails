class AddInitialCancellationReasons < ActiveRecord::Migration[6.1]
  def up
    CancellationReason.where({"reason"=>"I have a scheduling conflict", "reason_equivalent"=>"CANCELED > 48 HRS"}).first_or_create
    CancellationReason.where({"reason"=>"I no longer need the appointment", "reason_equivalent"=>"CANCELED > 48 HRS"}).first_or_create
    CancellationReason.where({"reason"=>"I am not able to attend due  to transportation issues", "reason_equivalent"=>"CANCELED > 48 HRS"}).first_or_create
    CancellationReason.where({"reason"=>"I am not able to attend due to an illness", "reason_equivalent"=>"ILLNESS"}).first_or_create
    CancellationReason.where({"reason"=>"The appointment was booked incorrectly", "reason_equivalent"=>"CANCELED > 48 HRS"}).first_or_create
    CancellationReason.where({"reason"=>"Other", "reason_equivalent"=>"CANCELED > 48 HRS"}).first_or_create
  end

  def down
    CancellationReason.delete_all
  end
end
