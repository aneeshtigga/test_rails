class CreateAvailabilityBlockOutRules < ActiveRecord::Migration[6.1]
  def change
    create_table :availability_block_out_rules do |t|
      t.integer :hours
      t.timestamps
    end
  end
end
