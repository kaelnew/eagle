class Api::V1::UsersController < Api::V1::ApplicationController
  skip_before_action :auth!, only: :login
  before_action :auth_super!, only: %i(index create destroy)
  before_action :set_user, only: %i(show update destroy)

  def index
    @users = User.alive
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.set_default_password
      return render_suc
    end
    render json: {code: responses.client_error.code, msg: @user.error_msg}
  end

  def show
  end

  def update
    return render_suc if @user.update(user_params)
    render json: {code: responses.client_error.code, msg: @user.error_msg}
  end

  def destroy
    @user.remove!
    render_suc
  end

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

  def user_params
    params.require(:user).permit(:name, :avatar)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
