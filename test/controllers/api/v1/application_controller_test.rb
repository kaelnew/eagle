require 'test_helper'

class Api::V1::ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "the alive" do
    get api_v1_alive_path
    assert suc == jbody
  end
end
