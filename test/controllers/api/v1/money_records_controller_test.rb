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

    assert '/api/v1/money_records/options' == options_api_v1_money_records_path
    assert_routing({method: :get, path: options_api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'options'})

    assert '/api/v1/money_records/static' == static_api_v1_money_records_path
    assert_routing({method: :get, path: static_api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'static'})

    assert '/api/v1/money_records/static_tag_percent' == static_tag_percent_api_v1_money_records_path
    assert_routing({method: :get, path: static_tag_percent_api_v1_money_records_path}, {controller: CONTROLLER_NAME, action: 'static_tag_percent'})
  end

  test "index" do
    outgo.tag_list = 'invest'
    outgo.save
    get api_v1_money_records_path, headers: request_headers(davi_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    data = jbody.data
    page_info = data.page_info
    assert 1 == page_info.current_page
    assert 2 == page_info.total_count
    assert 1 == page_info.total_pages
    assert data.money_records.collect {|mr| mr['id']} == davi.money_records.happened_at_desc.pluck(:id)
    imr = data.invest_money_records.first
    assert imr.parent_label == '2019-05-07 支出100.0: 存款'
    assert imr.parent_value == 1
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

  test "update1" do
    income_amount = income.amount
    patch api_v1_money_record_path(income), headers: request_headers(davi_token),
      params: {money_record: {parent_id: income.parent.id, amount: income_amount}, id: income.id, tag: income.tag_list.first}
    assert suc == jbody
    income.reload
    assert income.subject == income.parent.subject
    assert income.personal_share == income.parent.personal_share_ratio * income_amount
  end

  test "destroy" do
    assert davi.money_records.first == outgo
    delete api_v1_money_record_path(outgo), headers: request_headers(davi_token)
    assert suc == jbody
    assert davi.money_records.first == income
  end

  test "options" do
    get options_api_v1_money_records_path, headers: request_headers(davi_token)
    assert_equal suc.code, jbody.code
    assert_equal suc.msg, jbody.msg
    re = {"tag_options"=>[{"label"=>"工资", "value"=>"salary"}, {"label"=>"饮食", "value"=>"food"}, {"label"=>"穿着", "value"=>"clothes"}, {"label"=>"住房", "value"=>"living"}, {"label"=>"交通", "value"=>"traffic"}, {"label"=>"通讯", "value"=>"communicate"}, {"label"=>"电子产品", "value"=>"electronic"}, {"label"=>"护肤", "value"=>"skin"}, {"label"=>"学习", "value"=>"learn"}, {"label"=>"旅游", "value"=>"travel"}, {"label"=>"礼物", "value"=>"gift"}, {"label"=>"娱乐", "value"=>"entertain"}, {"label"=>"保险", "value"=>"insurance"}, {"label"=>"育儿", "value"=>"child"}, {"label"=>"养老", "value"=>"parent"}, {"label"=>"人情", "value"=>"human"}, {"label"=>"医疗", "value"=>"medical"}, {"label"=>"投资", "value"=>"invest"}, {"label"=>"房贷", "value"=>"houseloan"}, {"label"=>"房租", "value"=>"houserent"}, {"label"=>"借债", "value"=>"borrow"}, {"label"=>"欠债", "value"=>"debt"}, {"label"=>"理赔", "value"=>"claim"}, {"label"=>"其他", "value"=>"other"}], "subject_options"=>[{"label"=>"纯个人", "value"=>"personal"}, {"label"=>"纯他人", "value"=>"other"}, {"label"=>"个人参股", "value"=>"mixed"}]}
    assert jbody.data.as_json == re
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
    assert 1.56 == data.total_invest_return
  end

  test "static_tag_percent" do
    get static_tag_percent_api_v1_money_records_path, headers: request_headers(davi_token)
    assert suc.code == jbody.code
    re = {"totals"=>[{"value"=>1.56, "name"=>"收入"}, {"value"=>100.0, "name"=>"支出"}], "incomes"=>[{"value"=>1.56, "name"=>"投资"}], "outgos"=>[{"value"=>100.0, "name"=>"投资"}]}
    assert jbody.data.as_json == re
  end
end
