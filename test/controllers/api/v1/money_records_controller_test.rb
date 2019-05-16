require 'test_helper'

class Api::V1::MoneyRecordsControllerTest < ActionDispatch::IntegrationTest
  CONTROLLER_NAME = 'api/v1/money_records'

  test "routes" do
    assert_equal '/api/v1/money_records', api_v1_money_records_path
    assert_equal '/api/v1/money_records/1', api_v1_money_record_path(outgo)

    assert_routing({method: :get, path: api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'index'})
    assert_routing({method: :post, path: api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'create'})
    assert_routing({method: :patch, path: api_v1_money_record_path(outgo)}, {controller: CONTROLLER_NAME, action: 'update', id: outgo.id.to_s})
    assert_routing({method: :put, path: api_v1_money_record_path(outgo)}, {controller: CONTROLLER_NAME, action: 'update', id: outgo.id.to_s})
    assert_routing({method: :delete, path: api_v1_money_record_path(outgo)}, {controller: CONTROLLER_NAME, action: 'destroy', id: outgo.id.to_s})

    assert '/api/v1/money_records/all_tag' == all_tag_api_v1_money_records_path
    assert_routing({method: :get, path: all_tag_api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'all_tag'})

    assert '/api/v1/money_records/static' == static_api_v1_money_records_path
    assert_routing({method: :get, path: static_api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'static'})
  end

  test "index" do
    outgo.tag_list = 'invest'
    outgo.save
    get api_v1_money_records_path, headers: request_headers(davi_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    data = jbody.data
    page_info = data.page_info
    assert page_info.current_page = 1
    assert page_info.total_count = 2
    assert page_info.total_pages = 1
    assert data.money_records.collect {|mr| mr['id']} == davi.money_records.pluck(:id)
    imr = data.invest_money_records.first
    assert imr.label == '2019-05-07 支出100.0: 存款'
    assert imr.value == 1
  end

  test "create" do
    not_exist_parent_id = 10000
    post api_v1_money_records_path, headers: request_headers(davi_token), params: {
      money_record: {parent_id: not_exist_parent_id}
    }
    assert mth_responses.client_error.code == jbody.code
    assert I18n.t('money_record.tag_blank_error') == jbody.msg

    post api_v1_money_records_path, headers: request_headers(davi_token), params: {
      tag: :invest, money_record: {parent_id: not_exist_parent_id}
    }
    assert status == unauthorized.status
    unauthorized.delete(:status)
    assert unauthorized == jbody
  end

  test "create1" do
    ha = Time.now.to_date
    money_record = {happened_at: ha.to_s, income_flag: :outgo, amount: 1.11, remark: 'test'}
    params = {tag: 'food', money_record: money_record}
    post api_v1_money_records_path, headers: request_headers(davi_token), params: params
    assert suc == jbody
    mr = davi.money_records.last
    assert mr.happened_at == ha
    assert mr.outgo?
    assert mr.amount == money_record[:amount]
    assert mr.remark == money_record[:remark]
    assert mr.tag_list == [params[:tag]]
  end

  test "update" do
    ha = Time.now.to_date
    money_record = {happened_at: ha.to_s, income_flag: :outgo, amount: 1.11, remark: 'test'}
    params = {tag: 'food', money_record: money_record}
    patch api_v1_money_record_path(outgo), headers: request_headers(davi_token), params: params
    assert suc == jbody
    outgo.reload
    assert outgo.happened_at == ha
    assert outgo.outgo?
    assert outgo.amount == money_record[:amount]
    assert outgo.remark == money_record[:remark]
    assert outgo.tag_list == [params[:tag]]
  end

  test "destroy" do
    assert davi.money_records.first == outgo
    delete api_v1_money_record_path(outgo), headers: request_headers(davi_token)
    assert suc == jbody
    assert davi.money_records.first == income
  end

  test "all_tag" do
    get all_tag_api_v1_money_records_path, headers: request_headers(davi_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    assert jbody.data.as_json == MoneyRecord.all_tags.as_json
  end

  test "static" do
    outgo.tag_list = 'invest'
    outgo.save
    get static_api_v1_money_records_path, headers: request_headers(davi_token)
    assert suc.code == jbody.code
    data = jbody.data
    assert 0 == data.total_houseloan
    assert 0 == data.total_houserent
    assert 100 == data.total_invest
    assert 0 == data.total_invest_return
  end
end
