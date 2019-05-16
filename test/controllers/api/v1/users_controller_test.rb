require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  CONTROLLER_NAME = 'api/v1/users'

  test "routes" do
    assert_equal '/api/v1/users', api_v1_users_path
    assert_equal '/api/v1/users/1', api_v1_user_path(administrator)

    assert_routing({method: :get, path: api_v1_users_path}, {controller: CONTROLLER_NAME, action: 'index'})
    assert_routing({method: :post, path: api_v1_users_path}, {controller: CONTROLLER_NAME, action: 'create'})
    assert_routing({method: :get, path: api_v1_user_path(administrator)}, {controller: CONTROLLER_NAME, action: 'show', id: administrator.id.to_s})
    assert_routing({method: :patch, path: api_v1_user_path(administrator)}, {controller: CONTROLLER_NAME, action: 'update', id: administrator.id.to_s})
    assert_routing({method: :put, path: api_v1_user_path(administrator)}, {controller: CONTROLLER_NAME, action: 'update', id: administrator.id.to_s})
    assert_routing({method: :delete, path: api_v1_user_path(administrator)}, {controller: CONTROLLER_NAME, action: 'destroy', id: administrator.id.to_s})

    assert_equal '/api/v1/login', api_v1_login_path
    assert_equal '/api/v1/logout', api_v1_logout_path

    assert_routing({method: :post, path: api_v1_login_path}, {controller: CONTROLLER_NAME, action: 'login'})
    assert_routing({method: :post, path: api_v1_logout_path}, {controller: CONTROLLER_NAME, action: 'logout'})

    assert_routing({method: :get, path: check_name_api_v1_user_path(administrator)}, {controller: CONTROLLER_NAME, action: 'check_name', id: administrator.id.to_s})

    assert_equal '/api/v1/user_info', api_v1_user_info_path
    assert_routing({method: :get, path: api_v1_user_info_path}, {controller: CONTROLLER_NAME, action: 'user_info'})
  end

  test "index" do
    get api_v1_users_path, headers: request_headers(administrator_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    assert_equal User.alive.pluck(:id), jbody.data.map(&:id)
  end

  test "create with empty password" do
    post api_v1_users_path, headers: request_headers(administrator_token), params: {
      user: {name: :myname, avatar: :myavatar, password: empty_pwd}
    }
    assert suc == jbody
    user = User.last
    assert_equal user.name.to_sym, :myname
    assert_equal user.avatar.to_sym, :myavatar
    assert user.password == User::DEFAULT_PASSWORD
  end

  test 'create with password' do
    post api_v1_users_path, headers: request_headers(administrator_token), params: {
      user: {name: :myname, avatar: :myavatar, password: default_pwd}
    }
    assert suc == jbody
    user = User.last
    assert_equal user.name.to_sym, :myname
    assert_equal user.avatar.to_sym, :myavatar
    assert_equal user.password, User::DEFAULT_PASSWORD
  end

  test "show" do
    get api_v1_user_path(davi), headers: request_headers(davi_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    assert_equal davi.id, jbody.data.id
    assert_equal davi.name, jbody.data.name
    assert_equal davi.avatar, jbody.data.avatar
  end

  test "update with empty password" do
    patch api_v1_user_path(davi), headers: request_headers(administrator_token), params: {
      user: {name: :newname, avatar: :newavatar, password: empty_pwd}
    }
    assert suc == jbody
    user = davi.reload
    assert user.name.to_sym == :newname
    assert user.avatar.to_sym == :newavatar
  end

  test "update with password" do
    patch api_v1_user_path(davi), headers: request_headers(administrator_token), params: {
      user: {name: :newname, avatar: :newavatar, password: new_password}
    }
    assert suc == jbody
    user = davi.reload
    assert user.name.to_sym == :newname
    assert user.avatar.to_sym == :newavatar
    assert_equal user.password, LONG_PASSWORD
  end

  test "destroy" do
    assert davi.alive?
    delete api_v1_user_path(davi), headers: request_headers(administrator_token)
    assert suc == jbody
    assert davi.reload.removed?
  end

  test 'check_name' do
    get check_name_api_v1_user_path(administrator), headers: request_headers(administrator_token)
    assert mth_responses.client_error.code == jbody.code
    assert I18n.t('user.name_blank_error') == jbody.msg
  end

  test 'check_name1' do
    get check_name_api_v1_user_path(administrator), headers: request_headers(administrator_token), params: {name: :newname}
    assert suc == jbody
  end

  test 'check_name2' do
    get check_name_api_v1_user_path(administrator), headers: request_headers(administrator_token), params: {name: administrator.name}
    assert suc == jbody
  end

  test 'check_name3' do
    get check_name_api_v1_user_path(administrator), headers: request_headers(administrator_token), params: {name: davi.name}
    assert mth_responses.client_error.code == jbody.code
    assert I18n.t('user.name_uniqueness_error') == jbody.msg
  end

  test "login" do
    # wrong name
    post api_v1_login_path, params: {name: :wrong}
    assert login_client_error == jbody

    # correct name and wrong password
    post api_v1_login_path, params: {name: administrator.name, password: :wrong_password}
    assert login_client_error == jbody

    # correct name and correct password
    post api_v1_login_path, params: {name: administrator.name, password: default_pwd}
    assert_nil User.current
    data = jbody.data
    assert_equal(mth.suc_with_data(data), jbody)
    administrator.reload
    assert administrator.auth?(data.token)
  end

  test "logout" do
    token = administrator.generate_token!
    Setting.token_expire_duration = 1
    realtime = Benchmark.realtime do
      post api_v1_logout_path, headers: request_headers(token)
      assert suc == jbody
    end
    sleep(1-realtime)
    post api_v1_logout_path, headers: request_headers(token)
    assert status == unauthorized.status
    unauthorized.delete(:status)
    assert unauthorized == jbody
  end

  test "user_info" do
    get api_v1_user_info_path, headers: request_headers(administrator_token)
    data = jbody.data
    assert_equal(mth.suc_with_data(data), jbody)
    assert data.access == Setting.accesses['super']
  end
end
