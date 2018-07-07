require 'test_helper'

class FacilitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Searchkick.enable_callbacks
    Facility.delete_all

    @f1 = create(:facility, name: 'Golden Pond', description: 'Excelent Care')
    @f2 = create(:facility, name: 'Silver Lining', description: 'Incredible Care')
    @f3 = create(:facility, name: 'Gray Peaks', description: 'Incredible Service')

    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  teardown do
    Searchkick.disable_callbacks
  end

  test "search facilities" do
    Facility.reindex

    get "/v1/facilities", params: {q: 'Care'}
    assert_response :success
    assert_equal [@f1.id.to_s, @f2.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f1.name, @f2.name], json_response['data'].collect {|result| result['attributes']['name']}

    get "/v1/facilities", params: {q: 'Incredible'}
    assert_response :success
    assert_equal [@f2.id.to_s, @f3.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f2.name, @f3.name], json_response['data'].collect {|result| result['attributes']['name']}

    get "/v1/facilities", params: {q: 'Service'}
    assert_response :success
    assert_equal [@f3.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f3.name], json_response['data'].collect {|result| result['attributes']['name']}
  end

  test "retrieve one" do
    get "/v1/facilities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal @f1.name, json_response['data']['attributes']['name']
  end

  test "anonymous users can get all facilities" do
    get "/v1/facilities"
    assert_response :success
  end

  test "authenticated users can get all facilities" do
    get "/v1/facilities", params: {access_token: @auth}
    assert_response :success
  end

  test "anonymous users cannot update facilities" do
    put "/v1/facilities/#{@f1.id}", params: {name: "Updated Facility"}
    assert_response 401 # unauthorized
  end

  test "authenticated users cannot update facilities" do
    put "/v1/facilities/#{@f1.id}", params: {name: "Updated Facility", access_token: @token}
    assert_response 401 # unauthorized
  end

  test "admin users can update facilities" do
    put "/v1/facilities/#{@f1.id}", params: {name: "Updated Facility", access_token: @admin_token}
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Facility", json_response['data']['attributes']['name']

    get "/v1/facilities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Facility", json_response['data']['attributes']['name']
  end
end
