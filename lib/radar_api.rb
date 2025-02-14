class RadarApi
  def self.geocode(address)
    response = RestClient.get("https://api.radar.io/v1/geocode/forward?query=#{address}", { Authorization: Rails.application.credentials.radar_api_key })
    JSON.parse(response.body)
  rescue StandardError => e
    ErrorLogger.report(e)
    {}
  end
end
