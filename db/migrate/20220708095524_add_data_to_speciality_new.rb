class AddDataToSpecialityNew < ActiveRecord::Migration[6.1]
  def change
    # array = []
    # ["ADD/ADHD","Focus and Concentration","Anxiety/Phobias/Panic Attacks","Childhood behavior issues","Couple's issues","Down or Depressed","Eating concerns","Men's Issues","Obsessions or Compulsions","Postpartum or peri-partum issues","PTSD or Trauma","Women's Issues","Sleep Issues"].each do |x|
    #   speciality = Speciality.where(name: x).first_or_create
    #   array << speciality.id
    # end
    # Speciality.where.not(id: array).update_all(active: false)
  end
end
