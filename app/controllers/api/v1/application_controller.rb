class Api::V1::ApplicationController < ActionController::API
  include Authable
  include Responsable

  after_action :clear_thread_variable
  skip_before_action :auth, only: :alive

  def alive
    render_suc
  end

  def ping
    render_suc_with_data(user_id: current_user.id)
  end

  private

  def current_user
    User.current
  end

  def set_current_user(user)
    User.current = user
  end

  def clear_thread_variable
    set_current_user(nil)
  end

  def set_page_default_params
    params[:page] = 1 if params[:page].blank?
    params[:per] = Setting.per_page if params[:per].blank?
  end
end
