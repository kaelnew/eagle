module UserAuthable
  extend ActiveSupport::Concern

  RSA256 = 'RS256'
  ALG_OF_RSA256 = {algorithm: RSA256}

  def generate_token!
    rsa_private = OpenSSL::PKey::RSA.generate(2048)
    rsa_public = rsa_private.public_key
    token = JWT.encode(payload, rsa_private, RSA256)
    update!(rsa_pub_key: rsa_public, rsa_pub_key_created_at: @now) ? token : false
  end

  def auth!(token)
    rsa_public = OpenSSL::PKey::RSA.new(rsa_pub_key)
    JWT.decode(token, rsa_public, true, ALG_OF_RSA256)
  rescue => e
    return false
  end

  def payload
    @now = Time.now
    {id: id, exp: @now.to_i + Setting.token_expire_duration}
  end

  def login!(encoded_pwd)
    decoded_pwd = Base64.decode64(encoded_pwd)
    password == RSA_PRIVATE_KEY.private_decrypt(decoded_pwd)
  rescue => e
    return false
  end
  
end