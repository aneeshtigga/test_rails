require "rails_helper"

describe JsonWebToken, type: :class do
  describe ".encode" do
    it "encode method when payload passed as string not hash will raise exception and return nil" do
      expect(JsonWebToken.encode("application_name")).to be(nil)
    end
  end

  describe ".decode" do
    it "decode token will return the string from which token is generated" do
      jwt_token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
      expect(JsonWebToken.decode(jwt_token)["application_name"]).to eq(Rails.application.credentials.ols_api_app_name)
    end

    it "decode method with token passed as any random string will raise exception and return nil" do
      expect(JsonWebToken.decode("djk")).to be(nil)
    end
  end
end
