# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:saml]

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def saml?
    !!saml_uid
  end

  def admin?
    true
  end
end
