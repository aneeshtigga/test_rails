module Amd
  module Api
    class UploadFileApi < BaseApi
      def upload_file(file)
        file_details = get_upload_data(file)
        payload = {
          ppmdmsg: {
            '@action': "uploadfile",
            '@class': "files",
            file: {
              '@name': file_details["name"],
              '@description': file_details["name"],
              '@filetype': file_details["type"],
              '@fileext': file_details["extension"],
              '@patientid': file.record.patient.amd_patient_id,
              '@savechanges': true,
              '@zipmode': "0", # "0" = The file contents are uncompressed, "2" = The file contents are zipped
              filecontents: Base64.encode64(file.download),
              grouplist: {
                group: {
                  '@id': 4,
                  '@code': "MISC",
                  '@name': "Miscellaneous",
                  categorylist: {
                    category: {
                      '@id': file_details["category_id"],
                      '@filegroupfid': "4",
                      '@code': "MIUNSP",
                      '@name': "Unspecified",
                      '@filetype': "0",
                      '@level': "0",
                      '@default': "1"
                    }
                  }
                }
              }
            }
          }
        }.to_json

        resp = send_request(payload)
        resp = JSON.parse(resp.body)

        if resp.dig("PPMDResults", "Results")&.key? "filelist"
          resp.dig("PPMDResults", "Results", "filelist", "file")
        else
          resp.dig("PPMDResults", "Error")
        end
      end

      def delete_upload_file(file_id)
        payload = {
          ppmdmsg: {
          '@action': "deletefile",
          '@class': "files",
          '@msgtime': msgtime,
          '@ltq': msgtime,
          '@fileid': file_id,
          '@la': "deletefile",
          '@lac': "files",
          '@lst': msgtime
          }
        }.to_json

        resp = send_request(payload)
        resp = JSON.parse(resp.body)
        
        if resp.dig("PPMDResults", "Results")
          resp.dig("PPMDResults", "Results")
        else
          resp.dig("PPMDResults", "Error")
        end
      rescue StandardError => e
        {}
      end

      private

      def pdf_to_image(file)
        image_data =
          MiniMagick::Tool::Convert.new do |convert|
            convert.background "white"
            convert.density 300
            convert.quality 100
            convert.append
            convert << file.record.pdf_url
            convert << "png:-"
          end

        Base64.encode64(image_data).delete("\n")
      end

      def get_upload_data(file)
        file_details = {}
        view = (file.name == "back_card") ? "BackView" : "FrontView" 
        file_details["name"] = "InsuranceCard#{view}"
        file_details["extension"] = "jpeg"
        file_details["type"] = "I"
        file_details["category_id"] = Rails.application.credentials.amd[:insurance_card_category_id]
        file_details
      end
    end
  end
end
