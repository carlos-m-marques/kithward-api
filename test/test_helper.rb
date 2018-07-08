ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

require 'json_web_token'

#-- Search Kick --------
Searchkick.disable_callbacks
Community.search_index.clean_indices
Community.search_index.delete rescue nil
Community.reindex(import: false)

#-- Geocoder -----------
Geocoder.configure(lookup: :test)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  def json_response
    @json_cache ||= {}
    @json_cache[@response] ||= ActiveSupport::JSON.decode @response.body
  end
end
