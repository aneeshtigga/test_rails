class AddCboFieldToTypeOfCares < ActiveRecord::Migration[6.1]
  def change
    add_column :type_of_cares, :cbo, :integer
  end
end
