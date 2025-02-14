class AddDataToSpecialityTable < ActiveRecord::Migration[6.1]
   def self.up
#     [{name: "Depression", age_type: 2}, {name: "Anxiety", age_type: 2}, {name: "ADD/ADHD", age_type: 2},  {name: "Sleep Problems", age_type: 2},  {name: "Stress", age_type: 2},  {name: "Addiction/Substance Use", age_type: 2},  {name: "Grief Counseling", age_type: 2}, {name: "Anger Management / Mood Swings", age_type: 2}, {name: "Eating Disorders", age_type: 2}, {name: "Personality Disorders", age_type: 2}, {name: "Couple Counseling", age_type: 0}, {name: "Conflict Resolution", age_type: 2}, {name: "Adolescent / Teen Issues", age_type: 1}, {name: "LGBTQ Issues", age_type: 2}, {name: "Phobias", age_type: 2}, {name: "Obsessive Compulsive Disorder (OCD)", age_type: 2}, {name: "PTSD/Trauma", age_type: 2}, {name: "Panic Attacks", age_type: 2}, {name: "Postpartum", age_type: 0}, {name: "Women’s Health Issues", age_type: 0}, {name: "Men’s Health Issues", age_type: 0}, {name: "Family Therapy", age_type: 2}, {name: "Geriatric Care", age_type: 2}, {name: "Medication Management", age_type: 2}, {name: "Childhood Issues", age_type: 1}, {name: "Other", age_type: 2}].each do |speciality|
#       Speciality.where(speciality).first_or_create
#     end
   end

#   def self.down
#     Speciality.delete_all
#   end
end
