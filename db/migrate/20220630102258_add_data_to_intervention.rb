class AddDataToIntervention < ActiveRecord::Migration[6.1]
  def change
    ["Acceptance and Commitment Therapy","CBT for Insomnia","Cognitive Behavioral Therapy (CBT)","Couples/Marital Counseling","Psychological Testing","Neuropsychological Testing","Exposure Therapy","Family Therapy","Faith-Based Treatment","Dialectical Behavior Therapy (DBT)","EMDR","Bio-feedback","Christian Counseling","Exposure Therapy","Parent Child Interaction Therapy","Transcranial Magnetic Stimulation (TMS)","Spravato/Ketamine","Parenting Skills","Gender-Affirmative Medical Readiness Evaluations","Medical Procedure Evaluations","Mindfulness"].each do |intervention|
      Intervention.where(name: intervention).first_or_create
    end
  end
end
