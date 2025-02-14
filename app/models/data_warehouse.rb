class DataWarehouse < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :data_warehouse, reading: :data_warehouse }
end
