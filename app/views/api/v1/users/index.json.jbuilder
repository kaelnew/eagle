json.partial! 'jshared/suc'
json.data do
  json.partial! 'jshared/page_info', locals: {datas: @users}
  json.users @users.as_json(only: %i(id name avatar role delete_status))
end
