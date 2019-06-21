require 'test_helper'

class Api::V1::ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "alive" do
    get api_v1_alive_path
    assert suc == jbody
  end

  test "ping" do
    get api_v1_ping_path
    assert unauthorized == jbody_with_status

    get api_v1_ping_path, headers: request_headers(davi_token)
    assert mth.suc_with_data(user_id: davi.id) == jbody
  end
end
