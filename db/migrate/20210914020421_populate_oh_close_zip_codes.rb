class PopulateOhCloseZipCodes < ActiveRecord::Migration[6.1]
  def change
    # This hits the zip code API **EVERY** time we deploy (regardless of where we deploy).
    # It costs money, and makes us exceed our API limit.
    # Since we already have the StatePostalCodeWorker, I am disabling this migration
    # PostalCode.update_zip_codes("OH")
  end
end
