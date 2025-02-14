class CreateHolidaySchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :holiday_schedules, if_not_exists: true,
                 comment: "HolidaySchedule establishes the days when the clinician offices are closed to observe a holiday.
                          The observed holiday can be global for all states when the value of the state column is 'all' or
                          specific to a single state. Only full days are taken off." do |t|
      t.string :state, default: "All", comment: "Global “All” for every state, and then state for specific state holidays"
      t.date :date
      t.boolean :workday, default: false, comment: "Whether it is a workday, (active)"
      t.string :description, comment: "Name or description for holiday"

      t.timestamps
    end
  end
end
