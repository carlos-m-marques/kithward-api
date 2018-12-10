require 'test_helper'

class CommunityImporterIntegrationTest < ActionDispatch::IntegrationTest
  setup do
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

    Geocoder::Lookup::Test.add_stub(
      "125 Broadway, New York, NY, 10001, USA", [
        {
          'latitude'     => 40.7501,
          'longitude'    => -74.00,
          'address'      => '123 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "200 Broadway, New York, NY, 10001, USA", [
        {
          'latitude'     => 40.85,
          'longitude'    => -74.00,
          'address'      => '123 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "123 Broadway, Washington, DC, 20001, USA", [
        {
          'latitude'     => 38.90,
          'longitude'    => -77.00,
          'address'      => '123 Broadway',
          'state'        => 'Washington',
          'state_code'   => 'DC',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "456 Broadway, New York, NY, 10002, USA", [
        {
          'latitude'     => 40.80,
          'longitude'    => -74.10,
          'address'      => '456 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "789 Broadway, New York, NY, 10003, USA", [
        {
          'latitude'     => 40.90,
          'longitude'    => -74.10,
          'address'      => '789 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    @c1 = create(:community, name: 'Silver Lining', description: 'Incredible Care', care_type: 'I', street: '123 Broadway', city: 'New York', state: 'NY', postal: '10001', country: 'USA')
    @c1.geocode; @c1.save
    @c2 = create(:community, name: 'Golden Pond', description: 'Excelent Care', care_type: 'A', postal: '10001')
    @c3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'A', postal: '10001')
    @c4 = create(:community, name: 'Deleted Community', description: 'Useless Service', status: Community::STATUS_DELETED, postal: '10001')
    @c5 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'I', postal: '20001')

    Community.reindex

    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "basic endpoint access control" do
    post "/v1/communities/import"
    assert_response 401 # unauthorized

    post "/v1/communities/import", params: {access_token: @token}
    assert_response 401 # unauthorized

    post "/v1/communities/import", params: {access_token: @admin_token}
    assert_response :success

    assert_equal [], json_response['entries']
    assert_equal [{'message' => "No data!"}], json_response['errors']
  end

  test "minimum field requirements" do
    data = <<-EOF
kwid, name, address, city, state, care_type
, Golden Peaks, 100 Broadway, New York, NY, I
EOF
    post "/v1/communities/import", params: {access_token: @admin_token, data: data}
    assert_response :success
    assert_match(/Entries require at least/, json_response['entries'][0]['errors'][0]['message'])

  end

  test "dry-run import data" do
    data = <<-EOF
kwid, name, address, city, state, postal, care_type
, Silver Lining, 123 Broadway, New York, NY, 10001, I
, Lining Silvers, 125 Broadway, New York, NY, 10001, I
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I
EOF

    post "/v1/communities/import", params: {access_token: @admin_token, data: data, dryrun: true}
    assert_response :success
    assert_equal({'header' => 'kwid', 'attr' => 'kwid', 'pos' => 0}, json_response['attrs'][0])
    assert_equal({'header' => 'name', 'attr' => 'name', 'pos' => 1}, json_response['attrs'][1])
    assert_equal({'header' => 'address', 'attr' => 'street', 'pos' => 2}, json_response['attrs'][2])
    assert_equal({'header' => 'city', 'attr' => 'city', 'pos' => 3}, json_response['attrs'][3])
    assert_equal({'header' => 'state', 'attr' => 'state', 'pos' => 4}, json_response['attrs'][4])
    assert_equal({'header' => 'postal', 'attr' => 'postal', 'pos' => 5}, json_response['attrs'][5])
    assert_equal({'header' => 'care_type', 'attr' => 'care_type', 'pos' => 6}, json_response['attrs'][6])

    assert_equal({
      'kwid' => nil,
      'name' => "Silver Lining", 'street' => "123 Broadway", 'city' => "New York", 'state' => "NY",
      'care_type' => "I", 'postal' => "10001", 'line_number' => 2
    }, json_response['entries'][0]['data'])
    assert_equal @c1.id, json_response['entries'][0]['community']['id']
    assert_equal 'name', json_response['entries'][0]['match']

    assert_equal({
      'kwid' => nil,
      'name' => "Lining Silvers", 'street' => "125 Broadway", 'city' => "New York", 'state' => "NY",
      'care_type' => "I", 'postal' => "10001", 'line_number' => 3
    }, json_response['entries'][1]['data'])
    assert_equal @c1.id, json_response['entries'][1]['community']['id']
    assert_equal 'geocoding', json_response['entries'][1]['match']
  end

  test "resend processed entries" do
    data = <<-EOF
kwid, name, address, city, state, postal, care_type
, Silver Lining, 123 Broadway, New York, NY, 10001, I
, Lining Silvers, 125 Broadway, New York, NY, 10001, I
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I
EOF

    post "/v1/communities/import", params: {access_token: @admin_token, data: data, dryrun: true}
    assert_response :success
    assert_equal @c1.id, json_response['entries'][1]['community']['id']
    assert_equal 'geocoding', json_response['entries'][1]['match']

    post "/v1/communities/import", params: {access_token: @admin_token, entries: json_response['entries'], attrs: json_response['attrs'], dryrun: true}
    assert_response :success
    assert_equal @c1.id, json_response['entries'][1]['community']['id']
    assert_equal 'geocoding', json_response['entries'][1]['match']

  end

  test "full run" do
    data = <<-EOF
kwid, name, address, city, state, postal, care_type, star_rating, description, process
, Silver Lining, 123 Broadway, New York, NY, 10001, I, 5, this is a test,
, Lining Silvers, 125 Broadway, New York, NY, 10001, I, 3, a test with \\, commas,
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I, 1, nothing to say,
, New Peaks, 456 Broadway, New York, NY, 10002, I, 4, a new community, yes
, Newer Peaks, 789 Broadway, New York, NY, 10003, I, 4, should not be processed,
EOF

    c = Community.find_by_name('New Peaks')
    assert_nil c

    c = Community.find_by_name('Newer Peaks')
    assert_nil c

    post "/v1/communities/import", params: {access_token: @admin_token, data: data}
    assert_response :success

    @c1.reload # Silver Lining
    assert_equal 5, @c1.data['star_rating']
    assert_equal "this is a test", @c1.description

    @c5.reload # Gray Peaks, in DC
    assert_equal 1, @c5.data['star_rating']
    assert_equal "nothing to say", @c5.description

    c = Community.find_by_name('New Peaks')
    assert_equal 4, c.data['star_rating']
    assert_equal "New Peaks", c.name
    assert_equal "a new community", c.description

    c = Community.find_by_name('Newer Peaks')
    assert_nil c  # Not flagged with 'process'
  end

end
