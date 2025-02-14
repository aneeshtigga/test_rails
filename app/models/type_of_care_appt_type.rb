class TypeOfCareApptType < DataWarehouse
  self.table_name = "data_source_ror.vw_type_of_care_appointment_mapping"
  self.table_name = "type_of_care_appt_type" if Rails.env.development? || Rails.env.test?

  def care_data
    {
      amd_license_key: amd_license_key,
      amd_appt_type_uid: amd_appt_type_uid,
      in_person_visit: in_person_visit,
      virtual_or_video_visit: virtual_or_video_visit,
      amd_appointment_type: amd_appointment_type,
      type_of_care: type_of_care,
      facility_id: facility_id,
      cbo: cbo
    }
  end

end
