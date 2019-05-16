json.partial! 'jshared/suc'
json.data do
  json.partial! 'jshared/page_info', locals: {datas: @mrs}
  json.money_records @mrs.as_json(only: %i(id happened_at income_flag amount remark), methods: %i(happened_at_str tag_label tag_value parent))
  json.invest_money_records @invest_mrs.as_json(only: [], methods: %i(label value))
end