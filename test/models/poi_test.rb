# == Schema Information
#
# Table name: pois
#
#  id              :bigint(8)        not null, primary key
#  name            :string(1024)
#  poi_category_id :bigint(8)
#  street          :string(1024)
#  city            :string(256)
#  state           :string(128)
#  postal          :string(32)
#  country         :string(64)
#  lat             :float
#  lon             :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :bigint(8)
#
# Indexes
#
#  index_pois_on_created_by_id    (created_by_id)
#  index_pois_on_poi_category_id  (poi_category_id)
#

require 'test_helper'

class PoiTest < ActiveSupport::TestCase
  test "Addresses are geocoded automatically" do
    Geocoder::Lookup::Test.reset
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

    poi = Poi.create(name: "Broadway Café", street: "123 Broadway", city: "New York", state: "NY", postal: "10001", country: "USA")

    assert_equal(40.75, poi.lat)
    assert_equal(-74.00, poi.lon)
  end
end
