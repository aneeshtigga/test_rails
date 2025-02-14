class CarrierInsurance < DataWarehouse
  default_scope -> { where(amd_is_active: true) }
  self.table_name = "data_source_ror.vw_carriers_mds_amd"
  self.table_name = "carrier_insurances" if Rails.env.development? || Rails.env.test?
  self.primary_key = "carriers_mds_amd_key" unless Rails.env.development? || Rails.env.test?

  def self.get_carrier_insurances
    CarrierInsurance.select(:mds_carrier_id, :mds_carrier_name, :amd_carrier_id, :amd_carrier_name, :amd_carrier_code, :license_key).distinct
  end
  
  def self.insurances_by_provider(provider_ids)
    CarrierInsurance.where(clinician_id: provider_ids).select("license_key", "facility_id", "clinician_id", "mds_carrier_name", "amd_carrier_id").distinct
  end

  def self.get_uniq_providers
    CarrierInsurance.select(:clinician_id).distinct.pluck(:clinician_id)
  end
end
