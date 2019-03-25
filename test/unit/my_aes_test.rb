require 'test_helper'

class MyAesTest < ActiveSupport::TestCase
  DEFAULT_DATA = 'adcdefg123456'

  test "encrypt and decrypt" do
    datas = MyAes.encrypt(DEFAULT_DATA)
    data = MyAes.decrypt(datas.data, datas.aes_key, datas.aes_iv)
    assert_equal DEFAULT_DATA, data
  end
end
