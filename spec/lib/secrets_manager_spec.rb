require "rails_helper"

RSpec.describe SecretsManager, type: :class do
  
  describe ".get" do
    it "calls get_secret_value" do
      response = double
      allow(response).to receive(:secret_string)

      expect_any_instance_of(Aws::SecretsManager::Client).to receive(:get_secret_value).and_return(response)

      SecretsManager.instance.get("saml_cert")
    end
  end

end