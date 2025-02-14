require "aws-sdk-s3"

class Clinician < ApplicationRecord
  has_many :patient_appointments, dependent: :destroy
  has_many :patients, through: :patient_appointments

  has_many :clinician_languages, dependent: :destroy
  has_many :languages, through: :clinician_languages

  has_many :clinician_special_cases, dependent: :destroy
  has_many :special_cases, through: :clinician_special_cases

  has_many :clinician_expertises
  has_many :expertises, through: :clinician_expertises

  has_many :clinician_concerns
  has_many :concerns, through: :clinician_concerns

  has_many :clinician_interventions
  has_many :interventions, through: :clinician_interventions

  has_many :clinician_populations
  has_many :populations, through: :clinician_populations

  has_many :clinician_license_types
  has_many :license_types, through: :clinician_license_types

  has_many :type_of_cares, dependent: :destroy
  has_many :facility_accepted_insurances
  has_many :insurances, through: :facility_accepted_insurances
  has_many :clinician_addresses, autosave: true, dependent: :destroy
  has_many :educations
  has_many :clinician_accepted_ages

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :npi, presence: true
  validates :provider_id, presence: true
  validates :license_key, presence: true


  scope :with_type_of_cares, ->(care) { joins(:type_of_cares).where('lower(type_of_cares.type_of_care) in (?)', care.downcase) }


  scope :languages, ->(language) { joins(:languages).where('lower(languages.name) in (?)', language) }
  scope :expertises, lambda { |expertises|
                         joins(:expertises).where(expertises: { name: expertises })
                     }
  scope :concerns, lambda { |concerns|
                         joins(:concerns).where(concerns: { name: concerns })
                   }
  scope :interventions, ->(interventions) { joins(:interventions).where(interventions: {name: interventions }) }

  scope :populations, ->(populations) { joins(:populations).where(populations: { name: populations }) }

  scope :with_special_cases, ->(special_cases) { joins(:special_cases).where(special_cases: { name: special_cases }) }

  scope :clinician_types, ->(clinician_type) { where(clinician_type: clinician_type) }

  scope :active, -> { where(deleted_at: nil) }

  scope :online_booking_go_live_date, -> { where("online_booking_go_live_date IS NULL OR online_booking_go_live_date < ?", Time.now) }

  scope :with_zip_codes, lambda { |zip_code|
                           joins(:clinician_addresses).where(clinician_addresses: { postal_code: zip_code })
                         }

  scope :with_license_keys, lambda { |office_keys|
                             joins(:clinician_addresses).where(clinician_addresses: { office_key: office_keys })
                            }

  scope :filter_by_full_name, lambda { |term|
                                where("lower(concat(first_name,' ',last_name)) LIKE ? or lower(concat(last_name,' ',first_name)) LIKE ?",
                                "%#{term.downcase}%", "%#{term.downcase}%")
                              }

  scope :filter_by_last_name, ->(term) { where("lower(last_name) LIKE ?", "%#{term.downcase}%") }

  scope :filter_by_first_name, ->(term) { where("lower(first_name) LIKE ?", "%#{term.downcase}%") }

  scope :with_pronouns, ->(pronouns) { where('lower(pronouns) in (?)', pronouns.map!(&:downcase)) }

  scope :with_gender, ->(gender) { where('lower(gender) in (?)', gender.map!(&:downcase)) }

  scope :office_visit, -> { where(in_office: true) }

  scope :video_visit, -> { where(video_visit: true) }

  scope :office_video_visit, -> { where(video_visit: true, in_office: true) }

  scope :with_insurances, lambda { |insurances, app_name|
    left_joins(:insurances).where(insurances: { 
      name: insurances,
      "#{Clinician.app_filter_field(app_name)}": true
    })
  }

  scope :with_accepted_insurances, -> { joins(:insurances) }

  scope :with_provider_ids, ->(provider_ids) { where(provider_id: provider_ids) }

  scope :with_accepted_ages, lambda { |age|
    left_joins(:clinician_accepted_ages)
      .where("(clinician_accepted_ages.min_accepted_age <= ? and clinician_accepted_ages.max_accepted_age >= ?) or (clinician_accepted_ages is null)",
    age.to_i, age.to_i)
  }

  scope :with_license_types, lambda { |credentials| 
    left_joins(:license_types).where("license_types.name in (?) OR license_types.name in (?)", credentials, [nil, ""])
  }

  scope :with_none_active_address, -> { left_joins(:clinician_addresses).where(clinician_addresses: {id: nil}) }

  scope :other_providers,  lambda { |clinician, facilities|
    joins(:clinician_addresses)
      .where("clinicians.id!=? and clinicians.clinician_type=? and clinician_addresses.facility_id in (?) and clinician_addresses.office_key = ?",
    clinician.id, clinician.clinician_type, facilities, clinician.license_key)
  }

  scope :supervisors, ->(clinician) { joins(:facility_accepted_insurances).where("clinician_id =?", clinician.id) }

  after_save :update_accepted_age_data

  def soft_delete
    # rubocop:disable Rails/SkipsModelValidations
    update_column(:deleted_at, Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def deleted?
    deleted_at.present?
  end

  def active?
    !deleted?    
  end

  # Uniquely? identify a clinician to a specific theoretical person
  #
  # According to the product owner, a single person can be two
  # or more theoretical clinicians because of the business rules
  # established with the CBO and license keys that enable AMD
  # to handle the require performance.
  #
  # cbo is a physical database seperation.  There are multiple instances
  #     of the AMD application running.  Each instances has its
  #     own database in which record IDs are not unique between
  #     the physical instances.
  #
  # license_key   is a logical separation of data within the contet
  #               of a single AMD database instance.
  #
  # provider_id   is expected to be unique within AMD's physical and
  #               logical context.
  #
  def unique_ident
    # SMELL:  Does not have the same fields as does the
    #         duplicates method.
    #
    { 
      cbo:          cbo,         # physical AMD context
      license_key:  license_key, # logical  AMD context
      provider_id:  provider_id  # AMD's ID
    }
  end

  # Return unique clinicians
  # query is an AREL on the Clinician model
  #
  # How do we get duplicate clinicians?  Don't know
  # its most likely a systemic data error in the
  # data warehouse due the inadequate AMD product.
  #
  def self.no_duplicates(query)
    return query if query.count <= 1

    uniquefier = Hash.new {|h,k| h[k] = []}

    query.to_a.each do |c|
      uniquefier[c.unique_ident] << c.id
    end

    cids  = uniquefier.map {|_k,v| v.first} # an arbitrary choice amoung duplicates

    where(id: cids)
  end

  def self.app_filter_field(app_name)
    return "obie_external_display" if app_name == "obie"
    return "abie_intake_internal_display" if app_name == "abie"

    raise "ClinicianAddress.app_filter_field called with unknown app_name: #{app_name}"
  end

  def self.type_of_care_criteria(cares)
    clinician_ids = TypeOfCare.with_care(cares).pluck(:clinician_id).uniq
    where(id: clinician_ids)
  end

  def self.modality_criteria(type = "")
    clinicians = office_visit if type == "in_office"
    clinicians = video_visit if type == "video_visit"
    clinicians = office_video_visit if type == "both"
    clinicians
  end

  def update_accepted_age_data
    ages_data = ages_accepted.split(",") if ages_accepted.present?
    array = []
    if ages_data.present?
      ages_data.each do |age_data|
        next if age_data.blank?

        if age_data.include? "+"
          min_accepted_age, max_accepted_age = age_data.squish.split("+")
          max_accepted_age = 200 if max_accepted_age.blank?
        else
          min_accepted_age, max_accepted_age = age_data.squish.split("-") 
          min_accepted_age, max_accepted_age = age_data.squish.split("–") if max_accepted_age.to_i.zero?
        end
        clinician_accepted_age = clinician_accepted_ages.where(min_accepted_age: min_accepted_age.to_i, max_accepted_age: max_accepted_age.to_i).first_or_create
        array << clinician_accepted_age.id
      end
    end
    clinician_accepted_ages.where.not(id: array.uniq).delete_all if array.present?
  end

  def self.match_with_special_case(clinician_id, special_case_id)
    clinician_match_flag = true
    special_case = SpecialCase.find_by(id: special_case_id)
    if special_case.present? && special_case.name != "None of the above"
      clinician_match_flag = ClinicianSpecialCase.where(clinician_id: clinician_id, special_case_id: special_case_id).present?
    end
    clinician_match_flag
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def presigned_photo
    profile_photo = photo
    if profile_photo.present? && profile_photo != "no photo"
      filename = profile_photo.split("/").last
      signer = Aws::S3::Presigner.new(client: aws_client)
      url = signer.presigned_url(
        :get_object,
            bucket: Rails.application.credentials.dig(:aws, :clinician_photo_bucket),
            key: filename
      )
    end
  end

  def aws_client
    Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:aws, :region),
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
    )
  end

  def self.mark_inactive
    deactivated_locations_count = 0
    deactivated_clinicians_count = 0
    Clinician.active.each do |clinician|
      clinician.clinician_addresses.each do |clinician_address|
        next if ClinicianLocationMart.where(clinician_id: clinician_address.provider_id, facility_id: clinician_address.facility_id, 
license_key: clinician_address.office_key, is_active: true).present?

        clinician_address.deleted_at = Time.now.utc
        clinician_address.save!
        deactivated_locations_count += 1
      end
      next if ClinicianMart.where(clinician_id: clinician.provider_id, license_key: clinician.license_key, is_active: true).present?

      clinician.soft_delete
      clinician.save!
      deactivated_clinicians_count += 1
    end

    {
      deactivated_locations_count: deactivated_locations_count,
      deactivated_clinicians_count: deactivated_clinicians_count,
      active_clinicians: Clinician.active.count,
      unactive_clinicians: Clinician.where.not(deleted_at: nil).count
    }
  end

  def mapped_clinician_type
    case clinician_type.try(:downcase)
    when 'apn', 'app', 'psychiatrist', 'psychiatric clinician', 'psychiatrist resident (md, od)'
      'Psychiatric Clinician'
    else
      'Psychotherapist'
    end
  end

  def insurances_for_app(app_name)
    insurances.where(insurances: { "#{Clinician.app_filter_field(app_name)}": true })
  end

  def self.duplicates
    # SMELL:  does not include the same fields as in the
    #         unique_ident method.
    #
    Clinician.select(:provider_id, :npi, :license_key)
             .where(deleted_at: nil)
             .group(:provider_id, :npi, :license_key)
             .having("count(*) > 1")
  end
end
