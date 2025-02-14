class AddDataToSpecialCase < ActiveRecord::Migration[6.1]
  def up
    [{name: "Recently discharged from a psychiatric hospital", age_type: 2}, {name: "Court-ordered treatment", age_type: 2}, {name: "Worker's compensation matter", age_type: 2},  {name: "Parental custody matter", age_type: 2},  {name: "Current legal matter", age_type: 2},  {name: "Disability paperwork", age_type: 2},  {name: "Currently experiencing suicidal thoughts", age_type: 2}, {name: "None of the above", age_type: 2}].each do |special_case|
      SpecialCase.unscoped.where(special_case).first_or_create
    end
  end

  def down
    SpecialCase.unscoped.delete_all
  end
end
