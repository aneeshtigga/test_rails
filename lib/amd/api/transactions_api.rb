module Amd
  module Api
    class TransactionsApi < BaseApi
      MERCHANT_ACCOUNT_NAME = "Card Not Present".freeze
      CCOF_NAME = "Credit card on file".freeze
      # RestClient.log = 'stdout' # uncomment this line to see the request headers and body in the console

      alias default_headers bearer_token_request_headers

      # Submits credit card on file data to AMD
      # returns true if the credit card was successfully added to AMD
      # returns false if there was an error
      def add_credit_card(opts = {})
        success = false
        url = "#{base_url}/creditcardsonfile"

        return false unless Amd::Api::TransactionsApi.valid_params?(opts)

        merchant_account_id = merchant_account(MERCHANT_ACCOUNT_NAME)&.dig("id")
        unless merchant_account_id
          ErrorLogger.report(StandardError.new("No AMD merchant account with name: #{MERCHANT_ACCOUNT_NAME}"))
          return success
        end

        payload = {
          cardPresent: false,
          excludeFromBillingWizard: false,
          paymentProcessor: 1,
          merchantAccountId: merchant_account_id,
          maxMonthLimit: 0,
          name: CCOF_NAME
        }.merge(opts)

        begin
          resp = RestClient.post(url, payload.to_json, bearer_token_request_headers)

          json_resp = JSON.parse(resp&.body)
          success = json_resp&.dig("id")&.present? # return true if id is present
        rescue StandardError => e
          # The call to save the credit card on file to AMD failed. This is not a critical error, so we don't want to
          # raise an exception. Instead, we want to log the error and return false.
          ErrorLogger.report(e)
          success
        ensure
          response = resp&.body || { data: nil }
          response = JSON.parse(e.http_body) if e&.try(:http_body)

          ApiLogWorker.perform_async({
            payload: payload || { data: nil }, response: response,
            headers: bearer_token_request_headers.to_json, url: url,
            time: Time.zone.now, api_action: "creditcardsonfile", api_class: "Amd::Api::TransactionsApi",
            response_code: resp&.code || e&.try(:http_code) || "",
            response_message: resp&.net_http_res&.message || "",
            api_method_call: "post"
          })
        end
      end

      # returns an array of merchant accounts from AMD
      # if there is an error, returns an empty array
      def merchant_accounts
        data = []
        begin
          url = "#{base_url}/payment/accounts"

          resp = RestClient.get(url, bearer_token_request_headers)

          data = JSON.parse(resp&.body) # returns an array of merchant accounts
        rescue StandardError => e
          ErrorLogger.report(e)
          data
        ensure
          response = resp&.body || { data: nil }
          response = JSON.parse(e.http_body) if e&.try(:http_body)

          ApiLogWorker.perform_async({
            payload: { data: nil }, response: response,
            headers: bearer_token_request_headers.to_json, url: url,
            time: Time.zone.now, api_action: "payment/accounts", api_class: "Amd::Api::TransactionsApi",
            response_code: resp&.code || e&.try(:http_code) || "",
            response_message: resp&.net_http_res&.message || "",
            api_method_call: "get"
          })
        end
      end

      # returns a merchant account from AMD with the given name
      def merchant_account(name)
        amd_merchant_account = nil
        merchant_accounts.each do |merchant_account|
          if merchant_account["accountName"] == name
            amd_merchant_account = merchant_account
            break
          end
        end

        ErrorLogger.report("No AMD merchant account with name: #{name}") unless amd_merchant_account
        amd_merchant_account
      end

      def credit_card_on_file?(amd_responsible_party_id)
        success = false
        url = "#{base_url}/creditcardsonfile?respPartyId=#{amd_responsible_party_id}"

        begin
          resp = RestClient.get(url, bearer_token_request_headers)

          json_resp = JSON.parse(resp&.body)
          json_resp.each do |credit_card|
            success = true if credit_card["name"] == CCOF_NAME
          end
          success
        rescue StandardError => e
          # The call to save the credit card on file to AMD failed. This is not a critical error, so we don't want to
          # raise an exception. Instead, we want to log the error and return false.
          ErrorLogger.report(e)
          success
        ensure
          response = resp&.body || { data: nil }
          response = JSON.parse(e.http_body) if e&.try(:http_body)

          ApiLogWorker.perform_async({
            payload: "{ respPartyId: #{amd_responsible_party_id} }", response: response, 
            headers: bearer_token_request_headers.to_json, url: url, time: Time.zone.now,
            api_action: "creditcardsonfile", api_class: "Amd::Api::TransactionsApi",
            response_code: resp&.code || e&.try(:http_code) || "",
            response_message: resp&.net_http_res&.message || "",
            api_method_call: "get"
          })
        end
      end

      def self.valid_params?(cc_params)
        required_params = %i[creditCardToken lastFourDigits expirationMonth expirationYear zipCode responsiblePartyId]
        required_params.each do |param|
          raise "Missing Parameter: #{param}" unless cc_params.include?(param) && cc_params[param].present?
        end
        true
      end
    end
  end
end
