require 'test_helper'

class CommunityImporterIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    DataDictionary::Community.stubs(:attributes).returns({
      care_type: {data: 'select', values: [{"A"=>"Assisted Living"}, {"I"=>"Independent Living"}], direct_model_attribute: true},
      name: {data: 'string', direct_model_attribute: true},
      street: {data: 'string', direct_model_attribute: true},
      city: {data: 'string', direct_model_attribute: true},
      state: {data: 'string', direct_model_attribute: true},
      postal: {data: 'string', direct_model_attribute: true},
      phone: {data: 'string'},
      notes: {data: 'text'},
      description: {data: 'text', direct_model_attribute: true},
      star_rating: {data: 'rating'},
      pool: {data: 'amenity'},
    }.with_indifferent_access)

    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.add_stub("123 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.75, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("125 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.7501, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("200 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.85, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("456 Broadway, New York, NY, 10002, USA", [{'latitude' => 40.80, 'longitude' => -74.10}])
    Geocoder::Lookup::Test.add_stub("789 Broadway, New York, NY, 10003, USA", [{'latitude' => 40.90, 'longitude' => -74.10}])
    Geocoder::Lookup::Test.add_stub("123 Broadway, Washington, DC, 20001, USA", [{'latitude' => 38.90, 'longitude' => -77.00}])

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
    assert_equal [{'error' => "No data!"}], json_response['messages']
  end

  test "minimum field requirements" do
    data = <<-END
kwid, name, address, city, state, care_type
, Golden Peaks, 100 Broadway, New York, NY, I
END
    post "/v1/communities/import", params: {access_token: @admin_token, data: data}
    assert_response :success
    assert_match(/Entries require at least/, json_response['entries'][0]['messages'][0]['error'])

  end

  test "dry-run import data" do
    data = <<-END
kwid, name, address, city, state, postal, care_type
, Silver Lining, 123 Broadway, New York, NY, 10001, I
, Lining Silvers, 125 Broadway, New York, NY, 10001, I
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I
END

    post "/v1/communities/import", params: {access_token: @admin_token, data: data, dryrun: true}
    assert_response :success
    assert_equal [
      {'attr' => "kwid", 'header' => "kwid", 'pos' => 0, 'definition' => nil},
      {'attr' => "name", 'header' => "name", 'pos' => 1, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "street", 'header' => "address", 'pos' => 2, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "city", 'header' => "city", 'pos' => 3, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "state", 'header' => "state", 'pos' => 4, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "postal", 'header' => "postal", 'pos' => 5, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "care_type", 'header' => "care_type", 'pos' => 6, 'definition' => {'data' => 'select',  'values'=>[{"A"=>"Assisted Living"}, {"I"=>"Independent Living"}], 'direct_model_attribute' => true}},
    ], json_response['attrs']

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
    data = <<-END
kwid, name, address, city, state, postal, care_type
, Silver Lining, 123 Broadway, New York, NY, 10001, I
, Lining Silvers, 125 Broadway, New York, NY, 10001, I
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I
END

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
    data = <<-END
kwid, name, address, city, state, postal, care_type, star_rating, description, process
, Silver Lining, 123 Broadway, New York, NY, 10001, I, 5, this is a test,
, Lining Silvers, 125 Broadway, New York, NY, 10001, I, 3, a test with \\, commas,
, Gray Peaks, 123 Broadway, Washington, DC, 20001, I, 1, nothing to say,
, New Peaks, 456 Broadway, New York, NY, 10002, I, 4, a new community, yes
, Newer Peaks, 789 Broadway, New York, NY, 10003, I, 4, should not be processed,
END

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
