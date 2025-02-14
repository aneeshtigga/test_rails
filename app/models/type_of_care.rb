class TypeOfCare < ApplicationRecord

  belongs_to :clinician
  validates :type_of_care, presence: true
  validates :amd_appt_type_uid, presence: true
  validates :amd_license_key, presence: true
  validates :facility_id, presence: true

  scope :with_care, ->(care) { where({ type_of_care: care }) }
  scope :with_postal_code, lambda { |postal_code|
                             eager_load(clinician: :clinician_addresses).where(clinician_addresses: { postal_code: postal_code })
                           }

  scope :with_non_testing_cares, -> { where.not({ type_of_care: TESTING_CARES }) }
  
  scope :with_non_follow_up_cares, -> {where.not('type_of_care ilike ?', 'Follow Up%')}

  scope :for_zip_codes, lambda { |postal_code|
    joins('inner join clinician_addresses
                              on clinician_addresses.facility_id = type_of_cares.facility_id
                              and clinician_addresses.office_key = type_of_cares.amd_license_key').where({ clinician_addresses: { postal_code: postal_code } }).select("DISTINCT type_of_care").order("type_of_care ASC")
  }

  scope :by_state, lambda { |state|
    joins('inner join clinician_addresses
                              on clinician_addresses.facility_id = type_of_cares.facility_id
                              and clinician_addresses.office_key = type_of_cares.amd_license_key').where({ clinician_addresses: { state: state } }).select("DISTINCT type_of_care").order("type_of_care ASC")
  }

  # method to import data from data warehouse
  def self.import_data
    type_of_cares = TypeOfCareApptType.distinct.pluck(:clinician_id, :amd_license_key)
    type_of_cares_synced = 0
    type_of_cares.each do |clinician_id, license_key|
      begin
        clinician = Clinician.find_by(provider_id: clinician_id, license_key: license_key)
        next unless clinician

        CreateTypeOfCaresWorker.perform_async(clinician.id)
        type_of_cares_synced += 1
      rescue StandardError => e
        ErrorLogger.report(e)
        Rails.logger.error "Typeofcare import_data issue clinician_id: #{clinician_id} license_key: #{license_key}"
      end
    end
    {
      type_of_cares_in_dw: type_of_cares.size,
      type_of_cares_synced: type_of_cares_synced,
    }
  end

  def self.create_data(clinician_id)
    type_of_cares_synced = 0
    clinician = Clinician.find_by(id: clinician_id)
    type_of_cares_deleted = clinician.type_of_cares.count
    type_cares_in_dw = TypeOfCareApptType.where(clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
    transaction do
      clinician.type_of_cares.delete_all
      type_cares_in_dw.each do |type_of_care|
        clinician.type_of_cares.create!(type_of_care.care_data)
        type_of_cares_synced += 1
      rescue StandardError => e
        ErrorLogger.report(e)
        Rails.logger.error type_of_care.inspect.to_s
      end
    end
    {
      type_of_cares_deleted: type_of_cares_deleted,
      type_of_cares_in_dw: type_cares_in_dw.size,
      type_of_cares_synced: type_of_cares_synced,
    }
  end

  # Method to filter typeOfCares by zip code
  def self.get_cares_by_zip_code(postal_code)
    TypeOfCare.for_zip_codes(postal_code).map(&:type_of_care)
  end

  def self.get_cares_by_state(state)
    TypeOfCare.by_state(state).map(&:type_of_care)
  end
end
