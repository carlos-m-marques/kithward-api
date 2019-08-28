ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

require 'json_web_token'

#-- Search Kick --------
Searchkick.disable_callbacks
[Community, GeoPlace, Poi].each do |model_klass|
  model_klass.search_index.clean_indices
  model_klass.search_index.delete rescue nil
  model_klass.reindex(import: false)
end

#-- Geocoder -----------
Geocoder.configure(lookup: :test)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_request = PaperTrail.request.enabled?
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.request.enabled = was_enabled_for_request
    end
  end

  def assert_hashes_equal(expected, actual, message = nil)
    full_message = [message, "Hashes were not equal, diff was:\n.\n", Hashdiff.diff(expected, actual)].compact.collect(&:to_s).join("\n")
    assert expected == actual, full_message
  end
end

class ActionDispatch::IntegrationTest
  def json_response
    @json_cache ||= {}
    @json_cache[@response] ||= ActiveSupport::JSON.decode(@response.body)
  end
end
