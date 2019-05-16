json.partial! 'jshared/suc'
json.data @user.as_json(only: %i(id name avatar), methods: :access)