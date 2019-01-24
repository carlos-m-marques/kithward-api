require 'test_helper'

class PoiCategoriesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    PoiCategory.delete_all

    @coffee = create(:poi_category, name: "Coffee")
    @shopping = create(:poi_category, name: "Shopping")

    Account.delete_all
    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "anyone can retrieve POI categories" do
    get "/v1/pois/categories"
    assert_response :success
    assert_equal [@coffee, @shopping].collect {|c| c.id.to_s}, json_response.collect {|r| r['id']}
  end

  test "anyone can retrieve specific POIs" do
    get "/v1/pois/categories/#{@coffee.id}"
    assert_response :success
    assert_equal @coffee.id.to_s, json_response['id']
    assert_equal "Coffee", json_response['name']
  end

  test "only admin users can create POI categories" do
    post "/v1/pois/categories", params: {name: "Restaurant"}
    assert_response 401 # unauthorized

    post "/v1/pois/categories", params: {name: "Restaurant", access_token: @token}
    assert_response 401 # unauthorized

    post "/v1/pois/categories", params: {name: "Restaurant", access_token: @admin_token}
    assert_response :success
    assert_equal "Restaurant", json_response['name']
  end
end
