class AddDataToConcern < ActiveRecord::Migration[6.1]
  def change
    [{:name=>"ADD/ADHD", :age_type=>"both"},
     {:name=>"Anxiety/Phobias/Panic Attacks", :age_type=>"both"},
     {:name=>"Childhood behavior issues", :age_type=>"both"},
     {:name=>"Couple's issues", :age_type=>"self"},
     {:name=>"Down or Depressed", :age_type=>"both"},
     {:name=>"Eating concerns", :age_type=>"both"},
     {:name=>"Focus and Concentration", :age_type=>"both"},
     {:name=>"Men's Issues", :age_type=>"self"},
     {:name=>"Obsessions or Compulsions", :age_type=>"both"},
     {:name=>"Postpartum or peri-partum issues", :age_type=>"self"},
     {:name=>"PTSD or Trauma", :age_type=>"both"},
     {:name=>"Sleep Issues", :age_type=>"both"},
     {:name=>"Women's Issues", :age_type=>"self"}].each do |concern|
      Concern.create(concern)
     end
  end
end
