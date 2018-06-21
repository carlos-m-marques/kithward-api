ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

require 'json_web_token'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def mock_authentication(token, user = nil)
    unless @default_auth_stubbed
      JsonWebToken.stubs(:verify).raises(JWT::VerificationError)
      @default_auth_stubbed = true
    end

    JsonWebToken.stubs(:verify).with(token).returns(true)
  end
end

class ActionDispatch::IntegrationTest
  def json_response
    @json_cache ||= {}
    @json_cache[@response] ||= ActiveSupport::JSON.decode @response.body
  end
end
