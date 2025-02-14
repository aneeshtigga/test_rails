# app/builders/postal_code_builder.rb

# The purpose of the PostalCodeBuilder  is to return a single Active Record
# instance of the PostalCode model when given one or more zip_codes.
# By convention, the first zip code in an Array is considered as the
# HOME zip code.

class PostalCodeBuilder
  def initialize(zip_codes_array)
    @zip_codes = zip_codes_array
  end

  def self.build(zip_codes_array)
    new(zip_codes_array).build
  end

  def build
    PostalCode.find_by(zip_code: Array(@zip_codes).first)
  end
end
