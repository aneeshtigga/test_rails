class Jose
  class ExpiredSignature < Exception; end

  class << self
    def decrypt_and_verify(jwe)
      decoded_jwe = JSON::JWT.decode(jwe, lfs_private_key)
      verified_payload = JSON::JWT.decode(decoded_jwe.plain_text, amd_public_key.public_key)
      verify_expiration(verified_payload["iat"])
      verified_payload
    end

    private

    def verify_expiration(iat)
      return if Rails.application.credentials.sso_debug == true

      raise ExpiredSignature if Time.now.utc >= (Time.at(iat) + 1.minute)
    end

    def lfs_private_key
      OpenSSL::PKey::RSA.new(File.read(certs_path.join('private.key')))
    end

    def amd_public_key
      OpenSSL::X509::Certificate.new(File.read(certs_path.join('advancedmd-pub-cert.pem')))
    end

    def certs_path
      path = Pathname.new("/lfs/certs/")
      path = Rails.root if Rails.env.development? || Rails.env.test?
      path
    end
  end
end

