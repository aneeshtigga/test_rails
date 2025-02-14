class State < ApplicationRecord
  validates :name, presence: true

  def self.get_all_states
    State.all.pluck(:name)
  end
end
