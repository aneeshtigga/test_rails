# spec/lib/soft_deletable_spec.rb

=begin 
  SoftDeletable is a reusable library module that adds
  a "soft delete" capability to models that wrap
  ActiveRecord tables.  It depends upon the table having a
  "deleted_at" timestamp column.
=end

require 'rails_helper'

RSpec.describe "module SoftDeletable" do 
  
  # emulate a child class of ActiveRecord::Base
  #
  class AnyClassMock
    include SoftDeletable

    attr_accessor :deleted_at

    def initialize
      @deleted_at = nil
    end

    def update_column(col_name, col_value)
      @deleted_at = col_value
    end
  end # class AnyClassMock


  # This is a "wrong" class because it does not
  # have a "deleted_at" attribute.
  #
  class WrongKindOfClassMock
    include SoftDeletable
  end # class AnyClassMock


  let(:any_class) {AnyClassMock.new}
  let(:bad_class) {WrongKindOfClassMock.new}

  before :each do
    any_class.deleted_at = nil
  end


  it ".soft_deletable?" do 
    expect(any_class.soft_deletable?).to eq(true)
    expect(bad_class.soft_deletable?).to eq(false)
  end


  it "is not soft_deleted?" do 
    expect(any_class.soft_deleted?).to eq(false)
  end


  it ".soft_delete" do 
    any_class.soft_delete
    expect(any_class.soft_deleted?).to eq(true)
  end


  it ".soft_delete!" do 
    any_class.soft_delete!
    expect(any_class.soft_deleted?).to eq(true)
  end


  it "to protect developers" do 
    expect(bad_class.soft_deletable?).to eq(false)

    expect{bad_class.soft_delete}.to    raise_error("NotSoftDeletable")
    expect{bad_class.soft_delete!}.to   raise_error("NotSoftDeletable")
    expect{bad_class.soft_deleted?}.to  raise_error("NotSoftDeletable")
  end
end # RSpec.describe "SoftDeletable" do 

__END__

These two methods were removed from SoftDeletable because
of potential confusing that might exist in future maintenance
programmers. 


  it ".active?" do 
    expect(any_class.soft_deleted?).to  eq(false)
    expect(any_class.active?).to        eq(true)

    any_class.soft_delete

    expect(any_class.soft_deleted?).to  eq(true)
    expect(any_class.active?).to        eq(false)
  end
  

  it ".inactive?" do 
    expect(any_class.soft_deleted?).to  eq(false)
    expect(any_class.active?).to        eq(true)
    expect(any_class.inactive?).to      eq(false)

    any_class.soft_delete

    expect(any_class.soft_deleted?).to  eq(true)
    expect(any_class.active?).to        eq(false)
    expect(any_class.inactive?).to      eq(true)
  end
