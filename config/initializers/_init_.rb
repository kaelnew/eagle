# OS = 'Linux'
# $os = OS.in?(`uname`) ? OS : :other

CREDENTIALS = Rails.application.credentials
RSA_PRIVATE_KEY = OpenSSL::PKey::RSA.new(CREDENTIALS[:rsa_private_key])

# ActsAsTaggableOn
ActsAsTaggableOn.strict_case_match = true

#qiniu
qiniu_conf = Rails.application.credentials[:qiniu]
Qiniu.establish_connection! access_key: qiniu_conf[:AccessKey], secret_key: qiniu_conf[:SecretKey]