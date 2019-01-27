require 'test_helper'

class PoiIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Community.delete_all
    @c1 = create(:community, name: "Golden Pond", description: "Excelent Care", care_type: 'I', lat: 40.75, lon: -73.97)
    @c2 = create(:community, name: "Silver Lining", description: "Incredible Care", care_type: 'I', lat: 40.72, lon: -74.00)

    PoiCategory.delete_all
    @coffee = create(:poi_category, name: "Coffee")
    @shopping = create(:poi_category, name: "Shopping")

    Poi.delete_all
    @cafe_lala = create(:poi, name: "Café Lalá", poi_category: @coffee, lat: 40.5, lon: -74.0)
    @bodega_123 = create(:poi, name: "Bodega 123", poi_category: @shopping, lat: 40.51, lon: -74.01)

    Community.connection.execute("DELETE FROM communities_pois")

    Account.delete_all
    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "only admin users can query POIs" do
    get "/v1/pois", params: {lat: 74, lon: 40, q: "Coffee"}
    assert_response 401 # unauthorized

    get "/v1/pois", params: {lat: 74, lon: 40, q: "Coffee", access_token: @token}
    assert_response 401 # unauthorized

    get "/v1/pois", params: {lat: 74, lon: 40, q: "Coffee", access_token: @admin_token}
    assert_response :success
  end

  test "only admins can create new POIs" do
    post "/v1/pois", params: {lat: 74, lon: 40, name: "Café Amber", category:  @coffee.id}
    assert_response 401 # unauthorized

    post "/v1/pois", params: {lat: 74, lon: 40, name: "Café Amber", category:  @coffee.id, access_token: @token}
    assert_response 401 # unauthorized

    post "/v1/pois", params: {lat: 74, lon: 40, name: "Café Amber", category_id:  @coffee.id, access_token: @admin_token}
    assert_response :success
  end

  test "admins can add POIs to communities" do
    post "/v1/communities/#{@c1.id}/pois", params: {id: @cafe_lala.id}
    assert_response 401 # unauthorized`

    post "/v1/communities/#{@c1.id}/pois", params: {id: @cafe_lala.id, access_token: @token}
    assert_response 401 # unauthorized`

    post "/v1/communities/#{@c1.id}/pois", params: {id: @cafe_lala.id, access_token: @admin_token}
    assert_response :success
    assert_equal [@cafe_lala.id.to_s], json_response.collect {|p| p['id']}
    assert_equal [@cafe_lala.name], json_response.collect {|p| p['name']}
  end

  test "admins can delete POIs to communities" do
    @c1.pois = [@cafe_lala]
    @c1.reload
    assert_equal @cafe_lala.id, @c1.pois[0].id

    delete "/v1/communities/#{@c1.id}/pois/#{@cafe_lala.id}", params: {}
    assert_response 401 # unauthorized`

    delete "/v1/communities/#{@c1.id}/pois/#{@cafe_lala.id}", params: {access_token: @token}
    assert_response 401 # unauthorized`

    delete "/v1/communities/#{@c1.id}/pois/#{@cafe_lala.id}", params: {access_token: @admin_token}
    assert_response :success
    assert_equal [], json_response
  end

  test "admins can add and delete POIs through the Community endpoint" do
    put "/v1/communities/#{@c1.id}", params: {pois: [id: @cafe_lala.id], access_token: @admin_token}
    assert_response :success
    assert_equal [@cafe_lala.id.to_s], json_response['pois'].collect {|p| p['id']}
    assert_equal [@cafe_lala.name], json_response['pois'].collect {|p| p['name']}

    put "/v1/communities/#{@c1.id}", params: {pois: [id: @cafe_lala.id, deleted: 'deleted'], access_token: @admin_token}
    assert_response :success
    assert_equal [], json_response['pois'].collect {|p| p['id']}
  end

  test "anyone can see what POIs have been listed for a community" do
    get "/v1/communities/#{@c1.id}/pois"
    assert_response :success
    assert_equal [], json_response

    post "/v1/communities/#{@c1.id}/pois/", params: {id: @cafe_lala.id, access_token: @admin_token}
    assert_response :success
    assert_equal [@cafe_lala.id.to_s], json_response.collect {|p| p['id']}
    assert_equal [@cafe_lala.name], json_response.collect {|p| p['name']}

    get "/v1/communities/#{@c1.id}/pois"
    assert_response :success
    assert_equal [@cafe_lala.id.to_s], json_response.collect {|p| p['id']}
    assert_equal [@cafe_lala.name], json_response.collect {|p| p['name']}

    get "/v1/communities/#{@c1.id}"
    assert_response :success
    assert_equal [@cafe_lala.id.to_s], json_response['pois'].collect {|p| p['id']}
    assert_equal [@cafe_lala.name], json_response['pois'].collect {|p| p['name']}
  end
end
