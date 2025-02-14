class AddDataToAddressType < ActiveRecord::Migration[6.1]
  def self.up
    %w[Home Office Mailing Billing].each_with_index do |value, index|
      AddressType.where(code: (index + 10).to_s, description: value, active: true).first_or_create
    end
  end

  def self.down
    AddressType.delete_all
  end
end
