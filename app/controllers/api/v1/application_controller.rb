class Api::V1::ApplicationController < ActionController::API
  include Authable
  include Responsable

  after_action :clear_thread_variable
  skip_before_action :auth!, only: :alive

  def alive
    render_suc
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
end
