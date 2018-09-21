# == Schema Information
#
# Table name: communities
#
#  id               :bigint(8)        not null, primary key
#  name             :string(1024)
#  description      :text
#  street           :string(1024)
#  street_more      :string(1024)
#  city             :string(256)
#  state            :string(128)
#  postal           :string(32)
#  country          :string(64)
#  lat              :float
#  lon              :float
#  old_data         :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  care_type        :string(1)        default("?")
#  status           :string(1)        default("?")
#  data             :jsonb
#  cached_image_url :string(128)
#

require 'test_helper'

class CommunityTest < ActiveSupport::TestCase
  setup do
    Geocoder::Lookup::Test.add_stub(
      "123 Broadway, New York, NY, 10001, USA", [
        {
          'latitude'     => 40.75,
          'longitude'    => -74.00,
          'address'      => '123 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )
  end

  test "Addresses are geocoded automatically" do
    community = Community.create(name: "Broadway Care", street: "123 Broadway", city: "New York", state: "NY", postal: "10001", country: "USA")

    assert_equal(40.75, community.lat)
    assert_equal(-74.00, community.lon)
  end
end
