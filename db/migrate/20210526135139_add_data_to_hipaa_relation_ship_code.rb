class AddDataToHipaaRelationShipCode < ActiveRecord::Migration[6.1]
  def self.up
    HipaaRelationshipCode.where(code: 1, description: "Spouse", active: true).first_or_create
    HipaaRelationshipCode.where(code: 4, description: "Grandfather or Grandmother", active: true).first_or_create
    HipaaRelationshipCode.where(code: 5, description: "Grandson or Grandaughter", active: true).first_or_create
    HipaaRelationshipCode.where(code: 7, description: "Nephew or Niece", active: true).first_or_create
    HipaaRelationshipCode.where(code: 10, description: "Foster Child", active: true).first_or_create
    HipaaRelationshipCode.where(code: 15, description: "Ward of the Court", active: true).first_or_create
    HipaaRelationshipCode.where(code: 17, description: "Stepson or Stepdaughter", active: true).first_or_create
    HipaaRelationshipCode.where(code: 18, description: "Self", active: true).first_or_create
    HipaaRelationshipCode.where(code: 19, description: "Child", active: true).first_or_create
    HipaaRelationshipCode.where(code: 20, description: "Employee", active: false).first_or_create
    HipaaRelationshipCode.where(code: 21, description: "Unknown", active: true).first_or_create
    HipaaRelationshipCode.where(code: 22, description: "Handicapped/Dependent", active: true).first_or_create
    HipaaRelationshipCode.where(code: 23, description: "Sponsored Dependent", active: true).first_or_create
    HipaaRelationshipCode.where(code: 24, description: "Dependent of Minor Dependent", active: true).first_or_create
    HipaaRelationshipCode.where(code: 29, description: "Significant Other", active: true).first_or_create
    HipaaRelationshipCode.where(code: 32, description: "Mother", active: true).first_or_create
    HipaaRelationshipCode.where(code: 33, description: "Father", active: true).first_or_create
    HipaaRelationshipCode.where(code: 36, description: "Emancipated Minor", active: true).first_or_create
    HipaaRelationshipCode.where(code: 39, description: "Organ Donor", active: false).first_or_create
    HipaaRelationshipCode.where(code: 40, description: "Cadaver Donor", active: true).first_or_create
    HipaaRelationshipCode.where(code: 41, description: "Injured Plaintiff", active: true).first_or_create
    HipaaRelationshipCode.where(code: 43, description: "Child Where Insured Has No Financial Responsibility",
                                active: true).first_or_create
    HipaaRelationshipCode.where(code: 53, description: "Life Partner", active: true).first_or_create
    HipaaRelationshipCode.where(code: "G8", description: "Other Relationship", active: true).first_or_create
  end

  def self.down
    HipaaRelationshipCode.delete_all
  end
end
