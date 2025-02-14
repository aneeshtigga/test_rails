# Create data needed for the provider
Pact.provider_states_for 'V1::ValidateZip Consumer' do
  set_up do
    PostalCode.create(zip_code: "36111", city: "Montgomery", state: "AL", latitude: 40.7128, longitude: -74.0060)
  end

  tear_down do
    PostalCode.destroy_all
  end
end


Pact.service_provider "V1::ValidateZip" do

  app { ProxyApp.new(Rails.application) }
  
  honours_pact_with 'V1::ValidateZip Consumer' do
    pact_uri "#{PACTS_PATH}/api_v1_validate_zip.json"
  end
end