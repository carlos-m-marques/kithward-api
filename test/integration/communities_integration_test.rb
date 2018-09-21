require 'test_helper'

class CommunitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @c1 = create(:community, name: 'Golden Pond', description: 'Excelent Care', care_type: 'A')
    @c2 = create(:community, name: 'Silver Lining', description: 'Incredible Care', care_type: 'I')
    @c3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'A')
    @c4 = create(:community, name: 'Deleted Community', description: 'Useless Service', status: Community::STATUS_DELETED)

    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "data dictionary" do
    get "/v1/communities/dictionary"
    assert_response :success

    assert_not_nil json_response[0]['section']
  end

  test "search communities" do
    Community.reindex

    get "/v1/communities", params: {q: 'Care'}
    assert_response :success
    assert_equal [@c1.id.to_s, @c2.id.to_s], json_response.collect {|result| result['id']}
    assert_equal [@c1.name, @c2.name], json_response.collect {|result| result['name']}

    get "/v1/communities", params: {q: 'Incredible'}
    assert_response :success
    assert_equal [@c2.id.to_s, @c3.id.to_s], json_response.collect {|result| result['id']}
    assert_equal [@c2.name, @c3.name], json_response.collect {|result| result['name']}

    get "/v1/communities", params: {q: 'Service'}
    assert_response :success
    assert_equal [@c3.id.to_s], json_response.collect {|result| result['id']}
    assert_equal [@c3.name], json_response.collect {|result| result['name']}

    get "/v1/communities", params: {q: 'Incredible', care_type: 'assisted'}
    assert_response :success
    assert_equal [@c3.id.to_s], json_response.collect {|result| result['id']}

    get "/v1/communities", params: {care_type: 'assisted'}
    assert_response :success
    assert_equal [@c1.id.to_s, @c3.id.to_s], json_response.collect {|result| result['id']}

    get "/v1/communities", params: {care_type: 'i'}
    assert_response :success
    assert_equal [@c2.id.to_s], json_response.collect {|result| result['id']}
  end

  test "retrieve one" do
    get "/v1/communities/#{@c1.id}"
    assert_response :success

    assert_equal @c1.id.to_s, json_response['id']
    assert_equal @c1.name, json_response['name']
  end

  test "anonymous users can get all communities" do
    Community.reindex

    get "/v1/communities"
    assert_response :success
  end

  test "authenticated users can get all communities" do
    Community.reindex

    get "/v1/communities", params: {access_token: @auth}
    assert_response :success
  end

  test "anonymous users cannot update communities" do
    put "/v1/communities/#{@c1.id}", params: {name: "Updated Community"}
    assert_response 401 # unauthorized
  end

  test "authenticated users cannot update communities" do
    put "/v1/communities/#{@c1.id}", params: {name: "Updated Community", access_token: @token}
    assert_response 401 # unauthorized
  end

  test "admin users can update communities" do
    put "/v1/communities/#{@c1.id}", params: {name: "Updated Community", access_token: @admin_token}
    assert_response :success

    assert_equal @c1.id.to_s, json_response['id']
    assert_equal "Updated Community", json_response['name']

    get "/v1/communities/#{@c1.id}"
    assert_response :success

    assert_equal @c1.id.to_s, json_response['id']
    assert_equal "Updated Community", json_response['name']
  end

  test "admin users can add images to communities" do
    put "/v1/communities/#{@c1.id}", params: {name: "Updated Community", access_token: @admin_token}
    assert_response :success

    assert_equal @c1.id.to_s, json_response['id']
    assert_equal "Updated Community", json_response['name']

    get "/v1/communities/#{@c1.id}"
    assert_response :success

    assert_equal @c1.id.to_s, json_response['id']
    assert_equal "Updated Community", json_response['name']
  end

  test "search communities by geo place" do
    @soho = GeoPlace.create(name: "SoHo", lat: 40.72, lon: -73.99)
    @jersey = GeoPlace.create(name: "Jersey Shore", lat: 40.21, lon: -74.00)

    @nyc1 = create(:community, name: 'NYC Houses', lat: 40.75, lon: -73.97)
    @nyc2 = create(:community, name: 'SoHo Care', lat: 40.72, lon: -74.00)
    @nj1 = create(:community, name: 'Jersey Shore', lat: 40.20, lon: -74.01)

    Community.reindex

    get "/v1/communities", params: {geo: @soho.id}
    assert_response :success
    assert_equal [@nyc1.id.to_s, @nyc2.id.to_s].sort, json_response.collect {|result| result['id']}.sort

    get "/v1/communities", params: {geo: @jersey.id}
    assert_response :success
    assert_equal [@nj1.id.to_s].sort, json_response.collect {|result| result['id']}.sort
  end

  test "update community data" do
    community = create(:community, name: "SoHo Care", description: "Incredible Service", data: {phone: "212 555 1234", web: "http://soho.nyc/"})

    get "/v1/communities/#{community.id}", params: {access_token: @admin_token}
    assert_response :success
    assert_equal "SoHo Care", json_response['name']
    assert_equal "Incredible Service", json_response['description']
    assert_equal "212 555 1234", json_response['data']['phone']
    assert_equal "http://soho.nyc/", json_response['data']['web']

    put "/v1/communities/#{community.id}", params: {name: "SoHo Cares", description: "Good Service", data: {phone: "212 555 9876", email: "info@soho.nyc"}, access_token: @admin_token}
    assert_response :success
    assert_equal "SoHo Cares", json_response['name']
    assert_equal "Good Service", json_response['description']
    assert_equal "212 555 9876", json_response['data']['phone']
    assert_equal "http://soho.nyc/", json_response['data']['web']
    assert_equal "info@soho.nyc", json_response['data']['email']

    get "/v1/communities/#{community.id}", params: {access_token: @admin_token}
    assert_response :success
    assert_equal "SoHo Cares", json_response['name']
    assert_equal "Good Service", json_response['description']
    assert_equal "212 555 9876", json_response['data']['phone']
    assert_equal "http://soho.nyc/", json_response['data']['web']
    assert_equal "info@soho.nyc", json_response['data']['email']
  end
end
