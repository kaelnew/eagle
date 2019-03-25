class MyAes
  class << self
    def encrypt(data)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      key = cipher.key = cipher.random_key
      iv = cipher.iv = cipher.random_iv
      encrypted_data = (cipher.update(data) << cipher.final)
      key = Base64.encode64(key)
      iv = Base64.encode64(iv)
      encrypted_data = Base64.encode64(encrypted_data)
      Hashie::Mash.new({aes_key: key, aes_iv: iv, data: encrypted_data})
    end

    def decrypt(data, key, iv)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.decrypt
      cipher.key = Base64.decode64(key)
      cipher.iv  = Base64.decode64(iv)
      data = Base64.decode64(data)
      cipher.update(data) << cipher.final
    end
  end
end