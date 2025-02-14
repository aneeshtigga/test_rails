class HolidaySchedule < ApplicationRecord
  validates :state, :date, presence: true

  scope :holidays, ->(state) { where("(upper(state)= 'ALL' OR upper(state) = upper(?)) and workday is false and date >= current_date ", state) }
end
