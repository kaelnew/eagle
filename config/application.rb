require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Eagle
  class Application < Rails::Application
    config.load_defaults 5.2
    config.active_record.belongs_to_required_by_default = false

    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'

    config.i18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
    config.i18n.default_locale = "zh-CN"
    config.autoload_paths << Rails.root.join('lib')

    #解决跨域问题
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  end
end
