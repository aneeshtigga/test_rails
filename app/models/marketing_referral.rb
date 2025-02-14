class MarketingReferral < ApplicationRecord
  scope :active, -> { where(active: true) }
  validates :display_marketing_referral, presence: true
  validates :amd_marketing_referral, presence: true
end

