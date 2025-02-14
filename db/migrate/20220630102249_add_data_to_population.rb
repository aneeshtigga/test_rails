class AddDataToPopulation < ActiveRecord::Migration[6.1]
  def change
    ["Women","Men","Adoption/Foster Care","LGBTQ+","Military/Veterans","Developmental Disabilities","Head injuries","First Responders","Autism Spectrum Disorders"].each do |population|
      Population.where(name: population).first_or_create
    end
  end
end
