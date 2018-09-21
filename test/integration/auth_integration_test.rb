require 'test_helper'

class AuthIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Account.delete_all

    @joe = create(:account, email: "joe@example.com", password: "j03")
  end

  test "users can login and get access tokens" do
    post "/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['email']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['email']
  end

  test "access tokens expire after 24 hours" do
    post "/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['email']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['email']

    travel 8.hours do
      get "/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response :success
    end

    travel 25.hours do
      get "/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response 401
    end
  end

  test "refresh tokens can be used to get new access tokens" do
    post "/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['email']

    travel 25.hours do
      get "/v1/accounts/#{@joe.id}", params: {access_token: token}
      assert_response 401

      post "/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response :success
      assert_equal @joe.email, json_response['email']
      new_token = json_response['meta']['access_token']

      get "/v1/accounts/#{@joe.id}", params: {access_token: new_token}
      assert_response :success
    end
  end

  test "after a password change, refresh tokens no longer work" do
    post "/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['email']

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    put "/v1/accounts/#{@joe.id}", params: {access_token: token, password: 'abc', password_confirmation: 'abc'}
    assert_response :success

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response 401
  end

  test "refresh tokens expire after 2 years" do
    post "/v1/auth/login", params: {email: @joe.email, password: "j03"}
    assert_response :success
    assert_equal @joe.email, json_response['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe.email, json_response['email']

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    travel 800.days do
      post "/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response 401
    end
  end
end
