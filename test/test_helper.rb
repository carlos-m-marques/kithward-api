ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

require 'json_web_token'

#-- Search Kick --------
Searchkick.disable_callbacks
Facility.search_index.clean_indices
Facility.search_index.delete rescue nil
Facility.reindex(import: false)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  def json_response
    @json_cache ||= {}
    @json_cache[@response] ||= ActiveSupport::JSON.decode @response.body
  end
end
