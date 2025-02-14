class LicenseKeyRule < ApplicationRecord
  belongs_to :license_key
  belongs_to :ruleable, polymorphic: true

  default_scope { where(active: true) }

  scope :insurance_rule_skip_flag, lambda { |license_key|
                                     joins(:license_key).where(license_keys: { key: license_key },
                                                                    rule_name: INSURANCE_SKIP_OPTION_RULE)
                                   }
  scope :availablity_block_out_for_license_key, lambda { |license_key|
                                   joins(:license_key).where(license_keys: { key: license_key },
                                                                  rule_name: AVAILABILITY_BLOCK_OUT_RULE)
                                        }

  scope :credit_card_enabled_on_file, ->(license_key) { joins(:license_key).where(license_keys: {key: license_key}, rule_name: 'enable_credit_card_onfile')}

  scope :credit_card_skip_disabled, ->(license_key) { joins(:license_key).where(license_keys: {key: license_key}, rule_name: 'disable_skip_credit_card')}

  def get_rule_object
    ruleable_type.constantize.find_by(id: ruleable_id)
  end

  def self.get_insurance_rule_skip_flag(license_key)
    license_key_rule = LicenseKeyRule.insurance_rule_skip_flag(license_key).last
    insurance_rule_object = license_key_rule.get_rule_object if license_key_rule.present?
    insurance_skip_option_flag = insurance_rule_object.try(:skip_option_flag)
    insurance_skip_option_flag = true if insurance_skip_option_flag.to_s.blank?
    insurance_skip_option_flag
  end

  def self.get_is_credit_card_enabled_on_file(license_key)
    license_key_rule = LicenseKeyRule.credit_card_enabled_on_file(license_key).last
    license_key_rule.present? && license_key_rule.get_rule_object.value=="true"  ? true : false
  end

  def self.get_is_credit_card_skip_disabled(license_key)
    license_key_rule = LicenseKeyRule.credit_card_skip_disabled(license_key).last
    license_key_rule.present? && license_key_rule.get_rule_object.value=="true"  ? true : false
  end

  def self.block_out_hours_for_license_key(license_key)
    block_out_rule = availablity_block_out_for_license_key(license_key).last

    if block_out_rule.present?
      block_out_rule.ruleable.hours
    else
      AVAILABILITY_BLOCK_OUT_DEFAULT
    end
  end
end
