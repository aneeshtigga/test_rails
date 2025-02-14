class AddNewDataToPopulation < ActiveRecord::Migration[6.1]
  def change
    ["Substance Use Disorders"].each do |population|
      Population.where(name: population).first_or_create
    end
  end
end
