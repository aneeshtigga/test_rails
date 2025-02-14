class SupportDirectory < ApplicationRecord
    validates :cbo, presence: true
    validates :license_key, presence: true
end 
