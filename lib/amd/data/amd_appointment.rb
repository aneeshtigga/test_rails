module Amd
  module Data
    class AmdAppointment
      attr_accessor :appointment

      def initialize(appointment)
        @appointment = appointment
      end

      def patientid
        appointment.patient.amd_patient_id
      end

      def columnid
        facility_id = appointment.clinician_address.facility_id
        provider_id = appointment.clinician.provider_id
        ClinicianAvailability.where(provider_id: provider_id, facility_id: facility_id).first&.column_id
      end

      def startdatetime
        appointment.start_time.in_time_zone("America/New_York").strftime('%Y-%m-%dT%H:%M:%S.%L')
      end

      def duration
        ((appointment.end_time - appointment.start_time) / 60).round
      end

      def profileid
        facility_id = appointment.clinician_address.facility_id
        provider_id = appointment.clinician.provider_id
        ClinicianAvailability.where(provider_id: provider_id, facility_id: facility_id).first&.profile_id
      end

      def type
        appointment.clinician.type_of_cares.map do |toc|
          { "id" => toc.amd_appt_type_uid,
            "name" => toc.amd_appointment_type }
        end
      end

      def episodeid
        client = appointment.patient.client
        client.episodes.episode_id(patientid)
      end

      def comments
        appointment.patient_appointment.appointment_note
      end

      def params
        { "patientid" => patientid,
          "columnid" => columnid,
          "startdatetime" => startdatetime,
          "duration" => duration,
          "profileid" => profileid,
          "episodeid" => episodeid,
          "type" => type,
          "comments" => comments }
      end

      def amd_appointment_id
        appointment.patient_appointment.amd_appointment_id
      end

      def cancel_params
        {
          "id" => amd_appointment_id
        }
      end

      def update_params
        {
          "id" => amd_appointment_id,
          "startdatetime" => startdatetime,
          "columnid" => columnid
        }
      end
    end
  end
end