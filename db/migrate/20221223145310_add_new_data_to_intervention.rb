class AddNewDataToIntervention < ActiveRecord::Migration[6.1]
  def change
    ["Bariatric Evaluation","Biofeedback","Educational Testing"].each do |intervention|
      Intervention.where(name: intervention).first_or_create
    end
  end
end
