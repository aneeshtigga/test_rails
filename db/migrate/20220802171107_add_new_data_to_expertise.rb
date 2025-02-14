class AddNewDataToExpertise < ActiveRecord::Migration[6.1]
  def change
    array = []
    ["ADHD", "Anxiety", "Childhood behavior issues", "Couple's issues", "Depression", "Eating Disorders", "Men's Issues", "Obsessive-Compulsive Disorder", "Post Partum Depression/Anxiety", "PTSD/Trauma", "Women's Issues", "Sleep Disorders/Insomnia", "Gender Identity", "Bipolar Disorder", "Hoarding", "Midlife Transitions", "Pain Management", "Medical conditions/health psychology", "Reproductive challenges", "School Avoidance", "Somatoform Disorders", "Grief", "Psychosis/Schizophrenia", "Later Life Transitions", "Alcohol & Drug Use Issues"].each do |x|
      expertise = Expertise.where(name: x).first_or_create
      array << expertise.id
    end
    Expertise.where.not(id: array).update_all(active: false)
  end
end
