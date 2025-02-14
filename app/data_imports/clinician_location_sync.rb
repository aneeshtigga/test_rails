# app/data_imports/clinician_location_sync.rb

=begin
  ClinicianLocationSync is a kind of service class
  used within the context of background jobs that
  synchronize information from the "golden master" of all
  truth, the data warehouse, and the PostgreSQL database 
  that supports the OBIE/ABIE applications.
=end

class ClinicianLocationSync

  # instances are being used to accumulate metrics
  # via class variables
  #
  def initialize
    # SMELL: Odd use of class variables
    @@updated_locations_count = 0
    @@new_locations_count     = 0
    @@deleted_locations_count = 0
  end


  # WARNING:  this method invokes multiple instances of the
  #           background job: ClinicianLocationUpdaterWorker
  #
  # Parameters:
  #   time_since is a Time object in UTC timezone
  #
  # Returns:
  #   A metrics Hash of the record counts effected
  #
  def import_data(time_since)
    location_marts(time_since)
      .pluck(
        :clinician_id,
        :license_key, 
        :cbo, 
        :facility_id
      ).each do |provider_id,  office_key,   cbo,  facility_id|
              #  clinician_id  license_key
        ClinicianLocationUpdaterWorker
          .perform_async(
            provider_id,  # aka clinician_id
            office_key,   # aka license_key
            cbo, 
            facility_id
          )
    end

    remove_stale_addresses

    result = {
      new_locations_count:      @@new_locations_count,
      updated_locations_count:  @@updated_locations_count,
      deleted_locations_count:  @@deleted_locations_count
    }

    result
  end


  # Retrieves records from the data warehouse via the model
  # ClinicianLocationMart.  Either all valid locations
  # are returned or only those valid records which
  # have been undated after a specific point in time.
  #
  # Parameters:
  #   time_since is a Time object in UTC timezone
  #
  # Returns:
  #   An ActiveRecord::Collection from ClinicianLocationMart
  #
  def location_marts(time_since)
    clinician_location_marts = ClinicianLocationMart.with_valid_location
    clinician_location_marts = clinician_location_marts.where("change_timestamp > ?", time_since) if time_since.present?

    clinician_location_marts
  end

  def remove_stale_addresses
    postgres_clinician_addresses = ClinicianAddress.where(deleted_at: nil)

    postgres_clinician_addresses.each do |clinician_address|
      clinician_location_mart_locations = ClinicianLocationMart.where(clinician_id: clinician_address.provider_id)

      if clinician_location_mart_locations.blank?
        clinician_address.soft_delete
        @@deleted_locations_count += 1
      end
    end
  end


  ##################################################################
  ## Class methods

  # Invokes the instance method import_data
  #
  # Parameters:
  #   time_since is either a Time object in UTC timezone
  #     with a default of yesterday at this same time of day
  #
  # Returns:
  #   See the instance method import_data
  #
  def self.import_data(time_since: (Time.now.utc - 1.day))
    new.import_data(time_since)
  end


  # Synchronize the ClinicianAddress model content
  # with the content from the ClinicianLocationMart
  # model that wraps address information in the
  # data warehouse.
  #
  # This method orchestrates two other class
  # methods to
  #   1.  add records found in the data warehouse
  #       to ClinicianAddress which are not already present
  #       in the PostgreSQL table;
  #   2.  modify records from ClinicianAddress which are
  #       found in the data warehouse ClinicianLocationMart
  #   3.  delete records from ClinicianAddress which are
  #       _NOT_ found in the data warehouse ClinicianLocationMart
  #
  # Parameters:
  #   provider_id ... Integer,  aka clinician_id
  #   office_key .... String,   aka license_key
  #   cbo ........... String,   "Central Business Office"
  #                     cannot be nil
  #   facility_id ... Integer
  #
  # Returns:
  #   an undetermined object; basically nothing useful.  Just ignore it.
  #
  def self.sync_data(
      provider_id,
      office_key,
      cbo,
      facility_id
    )

    raise BadParameterError, "CBO is nil" if cbo.nil?

    # NOTE: order of execution should not be important
    add_location(provider_id, office_key, cbo, facility_id)
    delete_location(provider_id)

  rescue => e
    ErrorLogger.report(e)
    Rails.logger.error "Error caught in sync_data facility_id: #{facility_id} office_key: #{office_key} provider_id: #{provider_id} cbo: #{cbo} date: #{Date.today}"
  end


  #############################################
  private


  # The data warehouse model ClinicianLocationMart is the
  # "golden master" of truth for address information. Any
  # addresses (aka locations) in it that are not also in
  # the ClinicianAddress model are added to the PostgreSQL
  # database
  #
  # Likewise any locations (aka addresses) that are common
  # between the data warehouse model ClinicianLocationMart and
  # ClinicianAddress is updated in the PostgreSQL.
  #
  # Side Effect:
  #   increments the class variables:
  #     @@new_locations_count
  #     @@updated_locations_count
  #
  # Parameters:
  #   See sync_data above
  #
  # Returns:
  #   an undetermined object; don't use it.
  #
  def self.add_location(provider_id, office_key, cbo, facility_id)
    begin

      raise BadParameterError, "CBO is nil" if cbo.nil?

      clinician = Clinician.where(provider_id: provider_id, license_key: office_key, cbo: cbo).includes(:clinician_addresses).first
      ClinicianLocationMart.where(
            clinician_id: provider_id,
            license_key:  office_key,
            cbo:          cbo,
            facility_id:  facility_id,
            is_active:    true
          )
        .with_valid_location
        .each do |address|

        clinician_address = clinician.clinician_addresses
                              .find_or_initialize_by(
                                address.clinician_location_keys
                              )

        clinician_address.assign_attributes(address.location_info)

        clinician_address.save!

        if clinician_address.created_at_changed?
          @@new_locations_count += 1
        else
          @@updated_locations_count += 1 #for audit
        end
      end
    rescue StandardError => e
      ErrorLogger.report(e)
      Rails.logger.error "Error occurred in add_location facility_id: #{facility_id} office_key: #{office_key} provider_id: #{provider_id} cbo: #{cbo} date: #{Date.today}"
    end
  end


  # Deletes records from ClinicianAddress which are
  # note found in the data warehouse ClinicianLocationMart.
  #
  # Side Effect:
  #   increments the class variables:
  #     @@deleted_locations_count
  #
  # Parameters:
  #   provider_id ... Integer, aka clinician_id
  #
  # Returns:
  #   an undetermined object; don't use it.
  #
  def self.delete_location(
      provider_id   # aka clinician_id
    )

    raise BadParameterError, "provider_id is nil" if provider_id.nil?

    clinician_addresses = ClinicianAddress
                            .where(
                              provider_id:  provider_id,
                            )

    clinician_addresses.each do |address|
      dw_locations  = ClinicianLocationMart
                        .where(
                          clinician_id: provider_id,
                          facility_id:  address.facility_id,
                          license_key:  address.office_key,
                          cbo:          address.cbo,
                          is_active:    true
                        )
                        .with_valid_location

      if dw_locations.blank?
        address.soft_delete
        @@deleted_locations_count += 1
      end
    end
  end
end
