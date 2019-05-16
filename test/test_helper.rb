ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start
require_relative '../config/environment'
require 'rails/test_help'
require 'test_constants'
require 'capybara/rails'
require 'capybara/minitest'
require 'minitest/mock'
require 'my_test_helper'

class ActiveSupport::TestCase
  fixtures :all

  # # Make the Capybara DSL available in all integration tests
  # include Capybara::DSL
  # # Make `assert_*` methods behave like Minitest assertions
  # include Capybara::Minitest::Assertions

  # setup do
  # end

  # # Reset sessions and driver between tests
  # # Use super wherever this method is redefined in your individual test classes
  # teardown do
  #   Capybara.reset_sessions!
  #   Capybara.use_default_driver
  # end

  # json
  def jbody
    @jbody = Hashie::Mash.new(JSON.parse(@response.body))
  end

  def administrator
    @administrator ||= users(:administrator)
  end

  def default_pwd
    rsa_public = RSA_PRIVATE_KEY.public_key
    rsa_encrypted_pwd = rsa_public.public_encrypt(User::DEFAULT_PASSWORD)
    Base64.encode64(rsa_encrypted_pwd)
  end

  def empty_pwd
    rsa_public = RSA_PRIVATE_KEY.public_key
    rsa_encrypted_pwd = rsa_public.public_encrypt('')
    Base64.encode64(rsa_encrypted_pwd)
  end

  def new_password
    rsa_public = RSA_PRIVATE_KEY.public_key
    rsa_encrypted_pwd = rsa_public.public_encrypt(LONG_PASSWORD)
    Base64.encode64(rsa_encrypted_pwd)
  end

  def administrator_token
    @administrator_token ||= administrator.generate_token!
  end

  def davi
    @davi ||= users(:davi)
  end

  def davi_token
    @davi_token ||= davi.generate_token!
  end

  def mth
    @mth ||= MyTestHelper.new
  end

  def mth_responses
    @mth_responses ||= mth.responses
  end

  def login_client_error
    @lce ||= Hashie::Mash.new(mth.login_client_error)
  end

  def suc
    @suc ||= Hashie::Mash.new(mth.suc)
  end

  def unauthorized
    @unauthorized ||= Hashie::Mash.new(mth.unauthorized)
  end

  def request_headers(token)
    {Authorization: "Bearer #{token}", Accept: 'application/json'}
  end

  def income
    @income ||= money_records(:income)
  end

  def outgo
    @outgo ||= money_records(:outgo)
  end
end
