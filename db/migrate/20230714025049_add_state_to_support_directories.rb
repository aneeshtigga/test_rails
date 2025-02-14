class AddStateToSupportDirectories < ActiveRecord::Migration[6.1]
  def change
    add_column  :support_directories, :state, :string#, comment: "For saving state code of support info"
  end
end
