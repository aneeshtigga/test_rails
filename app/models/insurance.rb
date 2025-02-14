class Insurance < ApplicationRecord
  default_scope -> { where(amd_is_active: true, is_active: true) }

  validates :name, presence: true

  has_many :facility_accepted_insurances, dependent: :destroy
  has_many :clinician_addresses, through: :facility_accepted_insurances
  has_many :clinicians, through: :facility_accepted_insurances

  scope :with_zip_codes, lambda { |zip_codes|
                           joins(:clinician_addresses).where(clinician_addresses: { postal_code: zip_codes })
                         }

  scope :enabled_for, lambda { |app_name|
    raise ArgumentError, 'app_name is required' unless app_name.in? %w[obie abie]
    return where(obie_external_display: true) if app_name == 'obie'
    return where(abie_intake_internal_display: true) if app_name == 'abie'
  }

  scope :with_state, lambda { |state|
    joins(:clinician_addresses).where(clinician_addresses: { state: state })
  }

  def self.accepted_insurances_by_state(state, app_name)
    Insurance.enabled_for(app_name).with_state(state).select(:name).order(:name).pluck(:name).uniq
  end

  def self.filter_for_app(app_name)
    raise ArgumentError, 'app_name is required' unless app_name.in? %w[obie abie]
    return { obie_external_display: true } if app_name == 'obie'
    return { abie_intake_internal_display: true } if app_name == 'abie'
  end
end
