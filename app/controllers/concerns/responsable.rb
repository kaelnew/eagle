module Responsable
  extend ActiveSupport::Concern

  included do
    define_setting_response(Setting.responses.keys)
    define_common_render(Setting.responses.keys + %w(login_client_error login_server_error))
  end

  def render_suc_with_data(data)
    render json: suc_with_data(data)
  end

  def suc_with_data(data)
    responses.suc.merge(data: data)
  end

  def responses
    Hashie::Mash.new(Setting.responses)
  end

  def login_client_error
    {code: responses.client_error.code, msg: I18n.t('user.login_fail')}
  end

  def login_server_error
    {code: responses.server_error.code, msg: I18n.t('server.exception')}
  end

  module ClassMethods
    def define_setting_response(names)
      names.each do |name|
        define_method(name) do
          responses[name]
        end
      end
    end

    def define_common_render(names)
      names.each do |name|
        define_method('render_' + name) do
          data = send(name)
          status = data[:status]
          data.delete(:status)
          if status.nil?
            render json: data
          else
            render json: data, status: status
          end
        end
      end
    end
  end
end