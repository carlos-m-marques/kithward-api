require 'test_helper'

class AuthIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Account.delete_all

    @joe = create(:account, email: "joe@example.com", password: "j03")
  end

  test "users can login and get access tokens" do
    post "/api/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']

    get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
  end

  test "access tokens expire after 24 hours" do
    post "/api/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']

    get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']

    travel 8.hours do
      get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response :success
    end

    travel 25.hours do
      get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response 401
    end
  end

  test "refresh tokens can be used to get new access tokens" do
    post "/api/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']

    travel 25.hours do
      get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response 401

      post "/api/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response :success
      assert_equal @joe.email, json_response['data']['attributes']['email']
      new_token = json_response['meta']['access_token']

      get "/api/v1/accounts/#{@joe.id}", params: {access_token: new_token}
      assert_response :success
    end
  end

  test "after a password change, refresh tokens no longer work" do
    post "/api/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']

    post "/api/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    put "/api/v1/accounts/#{@joe.id}", params: {access_token: token, password: 'abc', password_confirmation: 'abc'}
    assert_response :success

    post "/api/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response 401
  end

  test "refresh tokens expire after 2 years" do
    post "/api/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/api/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['data']['attributes']['email']

    post "/api/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    travel 800.days do
      post "/api/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response 401
    end
  end
end
