class ConfirmationToken < ApplicationRecord
  has_secure_token

  belongs_to :account_holder

  validates :token, uniqueness: true

  before_create do 
    self.expire_at = Time.now + 1.day
  end

  def set_expiry
    self.update(expire_at: Time.now + 1.day)
  end

  def active?
    self.expire_at > Time.now
  end  
end 
