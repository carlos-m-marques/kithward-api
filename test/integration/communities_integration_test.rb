require 'test_helper'

class CommunitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @f1 = create(:community, name: 'Golden Pond', description: 'Excelent Care')
    @f2 = create(:community, name: 'Silver Lining', description: 'Incredible Care')
    @f3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service')

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
    assert_equal [@f1.id.to_s, @f2.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f1.name, @f2.name], json_response['data'].collect {|result| result['attributes']['name']}

    get "/v1/communities", params: {q: 'Incredible'}
    assert_response :success
    assert_equal [@f2.id.to_s, @f3.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f2.name, @f3.name], json_response['data'].collect {|result| result['attributes']['name']}

    get "/v1/communities", params: {q: 'Service'}
    assert_response :success
    assert_equal [@f3.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@f3.name], json_response['data'].collect {|result| result['attributes']['name']}
  end

  test "retrieve one" do
    get "/v1/communities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal @f1.name, json_response['data']['attributes']['name']
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
    put "/v1/communities/#{@f1.id}", params: {name: "Updated Community"}
    assert_response 401 # unauthorized
  end

  test "authenticated users cannot update communities" do
    put "/v1/communities/#{@f1.id}", params: {name: "Updated Community", access_token: @token}
    assert_response 401 # unauthorized
  end

  test "admin users can update communities" do
    put "/v1/communities/#{@f1.id}", params: {name: "Updated Community", access_token: @admin_token}
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Community", json_response['data']['attributes']['name']

    get "/v1/communities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Community", json_response['data']['attributes']['name']
  end

  test "admin users can add images to communities" do
    put "/v1/communities/#{@f1.id}", params: {name: "Updated Community", access_token: @admin_token}
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Community", json_response['data']['attributes']['name']

    get "/v1/communities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal "Updated Community", json_response['data']['attributes']['name']
  end
end
