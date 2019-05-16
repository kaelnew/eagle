json.partial! 'jshared/suc'
json.data @users.as_json(only: %i(id name avatar role delete_status))