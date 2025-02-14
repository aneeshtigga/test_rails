class ApiRequestResponse < ApplicationRecord
  validates :payload, presence: true
  validates :response, presence: true
end
