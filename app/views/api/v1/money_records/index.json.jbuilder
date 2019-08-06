json.partial! 'jshared/suc'
json.data do
  json.partial! 'jshared/page_info', locals: {datas: @mrs}
  json.money_records @mrs.as_json(only: %i(id happened_at income_flag subject amount remark personal_share), methods: %i(tag_label tag_value subject_name parent_id happened_at_str))
  json.invest_money_records @invest_mrs.as_json(only: [], methods: %i(parent_label parent_value))
end