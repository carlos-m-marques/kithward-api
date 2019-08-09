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
