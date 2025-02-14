module Abie
  module V2
    class CliniciansSearchBuilder < Abie::CliniciansSearchBuilder
      private

      def build_serialized_clinician_list(params)
        params[:modality] = Array(params[:modality])
        params[:modality].map! { |entry| entry.match?(/office/i) ? 'in_office' : entry }
        params[:modality].map! { |entry| entry.match?(/video/i) ? 'video_visit' : entry }
        all_clinician_availabilities = @search_parameters[:max_clinicians_per_modality].present?

        ActiveModelSerializers::SerializableResource.new(
          @results.includes(
            :insurances,
            clinician: %i[languages interventions populations expertises concerns type_of_cares license_types]
          ),
          all_clinician_availabilities: all_clinician_availabilities,
          each_serializer:      Abie::V2::ClinicianSearchSerializer,
          availability_filter:  params[:availability_filter],
          license_key:          params[:license_key],
          modality:             params[:modality],
          patient_status:       params[:patient_status],
          postal_code:          get_postal_code(params[:zip_codes]),
          type_of_cares:        params[:type_of_cares],
          utc_offset:           params[:utc_offset]
        )
      end
    end
  end
end
