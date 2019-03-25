require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "password" do
    assert administrator.password == SHORT_PASSWORD
    administrator.password = LONG_PASSWORD
    assert administrator.reload.password == LONG_PASSWORD
  end

  test 'uniqueness of name' do
    ua = User.new({name: administrator.name + '_123'})
    assert ua.save
    ub = User.new({name: administrator.name})
    assert_not ub.save
    assert_equal I18n.t('user.name_uniqueness_error'), ub.errors.values.first.first
  end

  test 'authable' do
    token = administrator.generate_token!
    assert token
    decoded_token = administrator.auth!(token)
    assert decoded_token
  end

  test 'login!' do
    assert administrator.login!(administrator_pwd)
  end
end
