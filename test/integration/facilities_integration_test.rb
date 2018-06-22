require 'test_helper'

class FacilitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Facility.delete_all

    @f1 = create(:facility)
    @f2 = create(:facility)
    @f3 = create(:facility)

    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "retrieve all" do
    get "/api/v1/facilities"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data'][0]['id']
    assert_equal @f2.id.to_s, json_response['data'][1]['id']
    assert_equal @f3.id.to_s, json_response['data'][2]['id']

    assert_equal @f1.name, json_response['data'][0]['attributes']['name']
    assert_equal @f2.name, json_response['data'][1]['attributes']['name']
    assert_equal @f3.name, json_response['data'][2]['attributes']['name']
  end

  test "retrieve one" do
    get "/api/v1/facilities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal @f1.name, json_response['data']['attributes']['name']
  end

  test "anonymous users can get all facilities" do
    get "/api/v1/facilities"
    assert_response :success
  end

  test "authenticated users can get all facilities" do
    get "/api/v1/facilities", params: {jwt: @auth}
    assert_response :success
  end

  test "anonymous users cannot update facilities" do
    put "/api/v1/facilities/#{@f1.id}", params: {name: "Updated Facility"}
    assert_response 401 # unathorized
  end

  test "authenticated users cannot update facilities" do
    put "/api/v1/facilities/#{@f1.id}", params: {name: "Updated Facility", access_token: @token}
    assert_response 401 # unathorized
  end

  test "admin users can update facilities" do
    put "/api/v1/facilities/#{@f1.id}", params: {name: "Updated Facility", access_token: @admin_token}
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Facility", json_response['data']['attributes']['name']
  end
end
