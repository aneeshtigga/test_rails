class AddInsuranceRuleData < ActiveRecord::Migration[6.1]
  def change
    InsuranceRule.create(skip_option_flag: true) # one with skip flag
    InsuranceRule.create(skip_option_flag: false) # one with mandatory flag
  end
end
