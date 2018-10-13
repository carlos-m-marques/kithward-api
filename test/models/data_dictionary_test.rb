require 'test_helper'

class DataDictionaryTest < ActiveSupport::TestCase

  test "Community dictionary should be valid" do
    DataDictionary::Community.validate
    DataDictionary::Listing.validate
  end
end
