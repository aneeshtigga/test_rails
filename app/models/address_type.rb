class AddressType < ApplicationRecord
  default_scope { where(active: true) }
  validates :code, presence: true
  validates :description, presence: true
end
