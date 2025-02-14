class AmdApiSession < ApplicationRecord
  validates :office_code, presence: true
  validates :redirect_url, presence: true
  validates :token, presence: true

  scope :by_office_code, -> (office_code) { where(office_code: office_code) }

  def self.last_active_session
    where("created_at > ?", Time.now - TOKEN_REFRESH_DURATION).last
  end
end
