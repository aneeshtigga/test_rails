class SecretsManager
  include Singleton

  def get(secret_name, add_prefix: true)
    prefix = add_prefix ? SecretsManager.prefix : ""
    @client ||= client
    @client.get_secret_value(secret_id: "#{prefix}#{secret_name}").secret_string
  end

  def self.prefix
    "#{Rails.env}_"
  end
  
  private

  def client
    Aws::SecretsManager::Client.new(
      region: Rails.application.credentials.dig(:aws, :region),
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
    )
  end
end
