class Api::V1::UsersController < Api::V1::ApplicationController
  skip_before_action :auth, only: :login
  before_action :auth_super, only: %i(index create destroy)
  before_action :set_user, only: %i(show update destroy)
  before_action :predeal_password, only: %i(create update)
  before_action :set_page_default_params, only: :index

  def index
    @users = User.order(:id).page(params[:page]).per(params[:per])
  end

  def create
    user_params[:password] = User::DEFAULT_PASSWORD if user_params[:password].blank?
    @user = User.create!(user_params)
    return render_suc if @user.save
    render json: {code: responses.client_error.code, msg: @user.error_msg}
  end

  def show
  end

  def user_info
    return render_unauthorized if current_user.nil?
    @user = current_user
  end

  def update
    user_params.delete(:password) if user_params[:password].blank?
    return render_suc if @user.update(user_params)
    render json: {code: responses.client_error.code, msg: @user.error_msg}
  end

  def destroy
    @user.remove!
    render_suc
  end

  def check_name
    return render json: {code: responses.client_error.code, msg: I18n.t('user.name_blank_error')} if params[:name].blank?
    user = User.by_name(params[:name]).first
    return render_suc if user.nil? or user.id.to_s == params[:id]
    render json: {code: responses.client_error.code, msg: I18n.t('user.name_uniqueness_error')}
  end

  def login
    set_current_user(User.find_by(name: params[:name]))
    return render_login_client_error if current_user.nil? or !current_user.login?(params[:password])
    token = current_user.generate_token!
    return render_login_server_error if !token
    render_suc_with_data({token: token})
  end

  def logout
    render_suc
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit(:name, :avatar, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def predeal_password
    user_params[:password] = params[:password] if user_params[:password].nil?
    user_params[:password] = User.decrypt_password(user_params[:password])
  rescue => e
    return render_unauthorized
  end
end
