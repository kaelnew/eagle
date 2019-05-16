require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "password" do
    assert administrator.password == User::DEFAULT_PASSWORD
    administrator.password = LONG_PASSWORD
    assert administrator.reload.password == LONG_PASSWORD
  end

  test 'uniqueness of name' do
    ua = User.new({name: administrator.name + '_123'})
    assert ua.save
    ub = User.new({name: administrator.name})
    assert_not ub.save
    assert_equal I18n.t('user.name_uniqueness_error'), ub.error_msg
  end

  test 'authable' do
    token = administrator.generate_token!
    assert token
    decoded_token = administrator.auth?(token)
    assert decoded_token
  end

  test 'login!' do
    assert administrator.login?(default_pwd)
  end

  test 'role' do
    assert administrator.super?
    assert davi.common?
  end

  test "relations" do
    mrs = davi.money_records.to_a
    assert outgo.in?(mrs)
    assert income.in?(mrs)
  end
end
