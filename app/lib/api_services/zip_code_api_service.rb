require "rest-client"

module ZipCodeApiService
  def get_zip_code_by_state(state)
    request("#{base_url}/state-zips.json/#{state}")
  end

  def get_zip_code_degrees(zip_code)
    response = request("#{base_url}/info.json/#{zip_code}/degrees")
    response["timezone"]["timezone_identifier"] = "US/Arizona" if response["state"] == "AZ" && !az_navajo_nation_zip_codes.include?(response["zip_code"])
    response
  end

  def zip_codes_by_radius(zip_code:, distance: 60, unit: "mile")
    request("#{base_url}/radius.json/#{zip_code}/#{distance}/#{unit}")
  end

  private

  def request(url)
    response = RestClient.get(url)

    if response.code == 200
      JSON.parse(response.body)
    else
      raise response
    end
  rescue StandardError => e
    Rails.logger.error e.message.to_s
    # Raise an exception when ZipCodeApi quota is exceeded
    if e.try(:http_code) == 429
      raise ZipCodeApiQuotaLimitException, "ZipCodeApi hourly limit has reached"
    else
      raise ZipCodeApiException, e.message.to_s
    end
  end

  def base_url
    api_key = Rails.application.credentials.zipcodeApi_key
    api_url = Rails.application.credentials.zipcodeApi_URL

    "#{api_url}/#{api_key}"
  end

  def az_navajo_nation_zip_codes
    %w[85901
       86047
       86033
       85929
       85941
       85937
       86505
       86025
       86044
       85935
       86510
       85928
       85933
       86034
       86520
       86031
       85911
       86054
       86039
       84536
       85939
       86032
       86030
       86042
       85923
       86043
       85942
       86029
       85931
       85902
       85912
       85934]
  end
end
