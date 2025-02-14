require "rails_helper"

RSpec.describe GenderIdentity, type: :model do

  before(:all) do 
    GenderIdentity.delete_all

    FactoryBot.create(:gender_identity, :male)
    FactoryBot.create(:gender_identity, :female)
    FactoryBot.create(:gender_identity, :neither)
  end

  it ".gi_values_for_menu" do 
    expected = %w[Male Female Rock]
    expect(GenderIdentity.gi_values_for_menu).to eq(expected)
  end

  it ".gi_from_amd_gi" do 
    expect(GenderIdentity.gi_from_amd_gi('Man')).to     eq('Male')
    expect(GenderIdentity.gi_from_amd_gi('Rubble')).to  eq('Rock')
  end

  it ".amd_gi_from_gi" do 
    expect(GenderIdentity.amd_gi_from_gi('Female')).to  eq('Woman')
  end

  it ".amd_gi_ident_from_gi" do 
    expect(GenderIdentity.amd_gi_ident_from_gi('Female')).to eq(559)
  end


  context "with bad parameter" do

    it ".gi_from_amd_gi" do 
      expect {GenderIdentity.gi_from_amd_gi('XX')}.to raise_error(
        BadParameterError,
        "Invalid value for amd_gi: XX"
      )
    end

    it ".amd_gi_from_gi" do 
      expect {GenderIdentity.amd_gi_from_gi('XY')}.to raise_error(
        BadParameterError,
        "Invalid value for gi: XY"
      )
    end

    it ".amd_gi_ident_from_gi" do 
      expect(GenderIdentity.amd_gi_ident_from_gi('XY')).to eq(nil)
    end
  end
end