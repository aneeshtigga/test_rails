class ResponsibleParty < ApplicationRecord
  has_one :account_holder
  has_one :intake_address, as: :intake_addressable, dependent: :destroy
  has_many :insurance_coverages, foreign_key: :policy_holder_id, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :date_of_birth, presence: true
  validates :email, presence: true
  validates :first_name, uniqueness: { scope: [:last_name, :date_of_birth, :email] }, unless: :skip_dup_validation

  attr_accessor :skip_dup_validation

  before_validation :sanitize_dob

  def sanitize_dob
    self.date_of_birth = Date.strptime(date_of_birth, "%m/%d/%Y")
  rescue StandardError
    self.date_of_birth = date_of_birth.try(:to_date)
  end
end
