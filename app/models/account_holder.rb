class AccountHolder < ApplicationRecord
  belongs_to :responsible_party, optional: true
  has_many :intake_addresses, autosave: true, as: :intake_addressable
  has_many :patients
  has_many :patient_appointments, through: :patients
  has_one :confirmation_token

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :phone_number, presence: true
  validates :first_name, uniqueness: { scope: [:last_name, :date_of_birth, :email] }

  attr_accessor :provider_id, :exists_in_amd

  def amd_respparty_id
    responsible_party&.amd_id
  end

  def self_patient
    patients.where(account_holder_relationship: :self).first
  end

  def confirmation_email
    self[:confirmation_email] || email
  end
 
end
