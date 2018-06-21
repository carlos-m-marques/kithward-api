ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  def json_response
    @json_cache ||= {}
    @json_cache[@response] ||= ActiveSupport::JSON.decode @response.body
  end
end
