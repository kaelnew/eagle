source 'https://gems.ruby-china.com'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

gem 'rails', '~> 5.2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.12.4'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.8.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bcrypt', '~> 3.1.12'
gem 'mini_magick', '~> 4.9.3'
gem 'capistrano-rails'

gem 'redis', '~> 4.1.0'
gem 'virtus', '~> 1.0.5'
gem 'paper_trail', '~> 10.2.0'
gem 'jquery-rails'
gem 'bootstrap', '~> 4.3.1'
gem 'mini_racer'
gem 'rest-client', '~> 2.0.2'
gem 'hashie'
gem 'kaminari', '~> 1.1.1' #分页
gem 'rails-settings-cached', '~> 0.7.2' #缓存
gem 'rack-cors', :require => 'rack/cors'
gem 'jwt'
gem 'suggest_rb' # 用于反向查询method
gem 'acts-as-taggable-on', '~> 6.0'
gem 'qiniu', '>= 6.9.0'
gem "enumize"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'simplecov'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
