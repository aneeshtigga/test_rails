class SsoToken < ApplicationRecord
  has_secure_token :token, length: 36

  before_create do
    self.expire_at = Time.now + 1.minutes
  end

  def active?
    expire_at > Time.now
  end
end
