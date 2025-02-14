class AuditJob < ApplicationRecord
  enum status: { failed: 0, completed: 1 }

  validates :params,     presence: true, allow_blank: true
  validates :audit_data, presence: true, allow_blank: true
end
