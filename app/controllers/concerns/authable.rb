module Authable
  extend ActiveSupport::Concern

  included do
    before_action :auth
  end

  private

  def auth
    @headers = request.headers
    token = @headers['HTTP_AUTHORIZATION'].match(/^Bearer (.*)/m).to_a.last
    decoded_token = JWT.decode(token, nil, false)
    payload = decoded_token.first
    set_current_user(User.find_by(id: payload['id']))
    return render_unauthorized if !current_user.auth?(token)
  rescue => e
    return render_unauthorized
  end

  def auth_super
    return render_unauthorized if !current_user.super?
  end
end