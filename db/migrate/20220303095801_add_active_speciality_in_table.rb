class AddActiveSpecialityInTable < ActiveRecord::Migration[6.1]
  def change
    # array = []
    # ["General","PTSD/Trauma","ADD/ADHD","Addiction/Substance Use","Adolescent / Teen Issues","Family Therapy","Anger Management / Mood Swings","Geriatric Care","Phobias","LGBTQ Issues","Personality Disorders","Anxiety","Eating Disorders","Childhood Issues","Grief Counseling","Conflict Resolution","Couple Counseling","Depression","Postpartum","Obsessive Compulsive Disorder (OCD)","Sleep problems","Stress","Medication Management","Men's Health Issues","Panic Attacks","Women's Health Issues"].each do |speciality|
    #   speciality_data = Speciality.unscoped.where(name: speciality).first_or_create
    #   array << speciality_data.id
    # end
    # Speciality.unscoped.where(id: array).update_all(active: true)
    # Speciality.unscoped.where.not(id: array).update_all(active: false)
  end
end
