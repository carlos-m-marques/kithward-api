require 'test_helper'

class FacilitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Account.delete_all

    @account_a = create(:account)
    @account_b = create(:account)
    @account_admin = create(:account, is_admin: true)

    @token_a = JsonWebToken.access_token_for_account(@account_a)
    @token_b = JsonWebToken.access_token_for_account(@account_b)
    @token_admin = JsonWebToken.access_token_for_account(@account_admin)

  end

  test "only self or admin can access an account" do
    get "/api/v1/accounts/#{@account_a.id}"
    assert_response 401 # unauthorized

    get "/api/v1/accounts/#{@account_a.id}", params: {access_token: @token_b}
    assert_response 401 # unauthorized

    get "/api/v1/accounts/#{@account_b.id}", params: {access_token: @token_a}
    assert_response 401 # unauthorized

    get "/api/v1/accounts/#{@account_a.id}", params: {access_token: @token_a}
    assert_response :success

    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal @account_a.name, json_response['data']['attributes']['name']

    get "/api/v1/accounts/#{@account_a.id}", params: {access_token: @token_admin}
    assert_response :success

    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal @account_a.name, json_response['data']['attributes']['name']
  end

  test "only self or admin can update an account" do
    put "/api/v1/accounts/#{@account_a.id}", params: {name: "Updated Name"}
    assert_response 401 # unauthorized

    put "/api/v1/accounts/#{@account_a.id}", params: {name: "Updated Name", access_token: @token_b}
    assert_response 401 # unauthorized

    put "/api/v1/accounts/#{@account_b.id}", params: {name: "Updated Name", access_token: @token_a}
    assert_response 401 # unauthorized

    put "/api/v1/accounts/#{@account_a.id}", params: {name: "Updated Name", access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal "Updated Name", json_response['data']['attributes']['name']
    get "/api/v1/accounts/#{@account_a.id}", params: {access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal "Updated Name", json_response['data']['attributes']['name']

    put "/api/v1/accounts/#{@account_a.id}", params: {name: "Another Name", access_token: @token_admin}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal "Another Name", json_response['data']['attributes']['name']
    get "/api/v1/accounts/#{@account_a.id}", params: {access_token: @token_admin}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_equal "Another Name", json_response['data']['attributes']['name']
  end

  test "anyone can create a new account" do
    post "/api/v1/accounts", params: {email: "test@example.com", password: "123"}
    assert_response :success

    assert_equal "test@example.com", json_response['data']['attributes']['email']
    id = json_response['data']['id']

    post "/api/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response :success
    assert_equal "test@example.com", json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']

    get "/api/v1/accounts/#{id}", params: {access_token: token}
    assert_response :success
    assert_equal "test@example.com", json_response['data']['attributes']['email']
  end

  test "passwords can be changed" do
    post "/api/v1/accounts", params: {email: "test@example.com", password: "123"}
    assert_response :success

    assert_equal "test@example.com", json_response['data']['attributes']['email']
    id = json_response['data']['id']

    post "/api/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response :success
    assert_equal id, json_response['data']['id']
    assert_equal "test@example.com", json_response['data']['attributes']['email']
    token = json_response['meta']['access_token']

    put "/api/v1/accounts/#{id}", params: {password: "456", password_confirmation: "456", access_token: token}
    assert_response :success

    post "/api/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response 401

    post "/api/v1/auth/login", params: {email: "test@example.com", password: "456"}
    assert_response :success
  end

  test "email cannot be changed" do
    put "/api/v1/accounts/#{@account_a.id}", params: {email: "another@example.com", access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['data']['id']
    assert_not_equal "another@example.com", json_response['data']['attributes']['email']
  end

  test "cannot signup with an email used in another account" do
    post "/api/v1/accounts", params: {email: @account_a.email, password: "123"}
    assert_response :unprocessable_entity
    assert_equal({"email" => ["has already been taken"]}, json_response['errors'])
  end
end
