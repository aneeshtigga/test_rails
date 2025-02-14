Pact.service_provider "V1::GenerateToken" do
  honours_pact_with 'V1::GenerateToken Consumer' do
    pact_uri "#{PACTS_PATH}/api_v1_generate_token.json"
  end
end
