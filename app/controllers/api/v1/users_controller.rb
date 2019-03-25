class Api::V1::UsersController < Api::V1::ApplicationController
  skip_before_action :auth!, only: :login

  def login
    set_current_user(User.find_by(name: params[:name]))
    return render_login_client_error if current_user.nil? or !current_user.login!(params[:password])
    token = current_user.generate_token!
    return render_login_server_error if !token
    render_suc_with_data(token)
  end

  def logout
    render_suc
  end

  private
  
end
