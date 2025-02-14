require "rails_helper"

RSpec.describe DataWarehouse, type: :model do
  it "sets the database connection to ware house" do
    expect(DataWarehouse.abstract_class).to be true
    secondary_db = Rails.configuration.database_configuration[Rails.env]["data_warehouse"]["database"]
    expect(DataWarehouse.connection.current_database).to eq secondary_db
  end
end
