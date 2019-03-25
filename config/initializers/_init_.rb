# OS = 'Linux'
# $os = OS.in?(`uname`) ? OS : :other

CREDENTIALS = Rails.application.credentials
RSA_PRIVATE_KEY = OpenSSL::PKey::RSA.new(CREDENTIALS[:rsa_private_key])
