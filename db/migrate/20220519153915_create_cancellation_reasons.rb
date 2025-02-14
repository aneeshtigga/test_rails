class CreateCancellationReasons < ActiveRecord::Migration[6.1]
  def change
    create_table :cancellation_reasons do |t|
      t.string :reason
      t.string :reason_equivalent

      t.timestamps
    end
  end
end
