require 'test_helper'

class AccountsIntegrationTest < ActionDispatch::IntegrationTest
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
    get "/v1/accounts/#{@account_a.id}"
    assert_response 401 # unauthorized

    get "/v1/accounts/#{@account_a.id}", params: {access_token: @token_b}
    assert_response 401 # unauthorized

    get "/v1/accounts/#{@account_b.id}", params: {access_token: @token_a}
    assert_response 401 # unauthorized

    get "/v1/accounts/#{@account_a.id}", params: {access_token: @token_a}
    assert_response :success

    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal @account_a.name, json_response['name']

    get "/v1/accounts/#{@account_a.id}", params: {access_token: @token_admin}
    assert_response :success

    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal @account_a.name, json_response['name']
  end

  test "only self or admin can update an account" do
    put "/v1/accounts/#{@account_a.id}", params: {name: "Updated Name"}
    assert_response 401 # unauthorized

    put "/v1/accounts/#{@account_a.id}", params: {name: "Updated Name", access_token: @token_b}
    assert_response 401 # unauthorized

    put "/v1/accounts/#{@account_b.id}", params: {name: "Updated Name", access_token: @token_a}
    assert_response 401 # unauthorized

    put "/v1/accounts/#{@account_a.id}", params: {name: "Updated Name", access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal "Updated Name", json_response['name']
    get "/v1/accounts/#{@account_a.id}", params: {access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal "Updated Name", json_response['name']

    put "/v1/accounts/#{@account_a.id}", params: {name: "Another Name", access_token: @token_admin}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal "Another Name", json_response['name']
    get "/v1/accounts/#{@account_a.id}", params: {access_token: @token_admin}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['id']
    assert_equal "Another Name", json_response['name']
  end

  test "anyone can create a new account" do
    MailTools.expects(:send_template).once
    post "/v1/accounts", params: {email: "test@example.com", password: "123"}
    assert_response :success

    assert_equal "test@example.com", json_response['email']
    id = json_response['id']

    post "/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response :success
    assert_equal "test@example.com", json_response['email']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{id}", params: {access_token: token}
    assert_response :success
    assert_equal "test@example.com", json_response['email']
  end

  test "passwords can be changed" do
    MailTools.expects(:send_template).once
    post "/v1/accounts", params: {email: "test@example.com", password: "123"}
    assert_response :success

    assert_equal "test@example.com", json_response['email']
    id = json_response['id']

    post "/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response :success
    assert_equal id, json_response['id']
    assert_equal "test@example.com", json_response['email']
    token = json_response['meta']['access_token']

    put "/v1/accounts/#{id}", params: {password: "456", password_confirmation: "456", access_token: token}
    assert_response :success

    post "/v1/auth/login", params: {email: "test@example.com", password: "123"}
    assert_response 401

    post "/v1/auth/login", params: {email: "test@example.com", password: "456"}
    assert_response :success
  end

  test "email cannot be changed" do
    put "/v1/accounts/#{@account_a.id}", params: {email: "another@example.com", access_token: @token_a}
    assert_response :success
    assert_equal @account_a.id.to_s, json_response['id']
    assert_not_equal "another@example.com", json_response['email']
  end

  test "cannot signup with an email used in another account" do
    post "/v1/accounts", params: {email: @account_a.email, password: "123"}
    assert_response :unprocessable_entity
    assert_equal({"email" => ["has already been taken"]}, json_response['errors'])
  end
end
