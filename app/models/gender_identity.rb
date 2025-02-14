# frozen_string_literal: true

# == Schema Information
# Schema version: 20230602101223
#
# Table name: gender_identities
#
#  id           :bigint           not null, primary key
#  amd_gi       :string           default(""), not null, indexed
#  amd_gi_ident :integer          indexed
#  gi           :string           default(""), not null, indexed
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_amd_gi_ident                 (amd_gi_ident)
#  index_gender_identities_on_amd_gi  (amd_gi) UNIQUE
#  index_gender_identities_on_gi      (gi) UNIQUE
#
class GenderIdentity < ApplicationRecord
  # The GenderIdentity (aka gi) model wraps the gender_identities
  # database table.  It is basically nothing more than a cross
  # reference table between what the ABIE/OBIE applications use for gi
  # values and what the 3rd party EHR AMD uses for the same thing.  We
  # do not care about the case of the gi and amd_gi columns.  They are
  # in presentation case.  There is no direct patient entry of gi
  # values beyond selection from a menu; therefore, searches and
  # indexes do not need to be constrained to a specific case.
  #

  class << self 
    # Returns an Array of Strings for use
    # by the front-end in a menu that allows the
    # user to select a gender identity.  The
    # is in ascending order by the primary key (id)
    def gi_values_for_menu
      order(:id).pluck(:gi).uniq
    end

    ######################################################
    ## String-based retrievals

    # gi (String) is what is used within ABIE/OBIE
    # Returns a String for what is used within AMD
    # raises BadParameterError when gi is not found.
    def amd_gi_from_gi(gender_identity)
      result = where(gi: gender_identity)&.pluck(:amd_gi)&.first

      raise BadParameterError, "Invalid value for gi: #{gender_identity}" if result.blank?

      result
    end

    # amd_gi (String) is what AMD uses for gender identity
    # Returns a String used within ABIE/OBIE
    # raises BadParameterError when amd_gi is not found.
    def gi_from_amd_gi(amd_gi)
      result = where(amd_gi: amd_gi)&.pluck(:gi)&.first

      raise BadParameterError, "Invalid value for amd_gi: #{amd_gi}" if result.blank?

      result
    end


    ######################################################
    ## AMD GI Ident-based retrievals

    # gi (String) is what is used within ABIE/OBIE
    # Returns an Integer for what is used within AMD
    # 
    # IF gi is not valid - not in the table - return a nil value.
    #
    # In the AMD patient API, when this value is nil,
    # the "@genderidentity" field is NOT sent to AMD
    #
    def amd_gi_ident_from_gi(gender_identity)
      where(gi: gender_identity)&.pluck(:amd_gi_ident)&.first
    end

    # amd_gi_ident (Integer) is what AMD uses for gender identity
    # Returns a String used within ABIE/OBIE
    # raises BadParameterError when amd_gi is not found.
    def gi_from_amd_gi_ident(amd_gi_ident)
      result = where(amd_gi_ident: amd_gi_ident)&.pluck(:gi)&.first

      raise BadParameterError, "Invalid value for amd_gi_ident: #{amd_gi_ident}" if result.blank?

      result
    end
  end
end