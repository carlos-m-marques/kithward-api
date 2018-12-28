require 'test_helper'
require 'mail_tools'

class AuthIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Account.delete_all

    @joe_real = create(:account, email: "joe@example.com", password: "j03")
    MailTools.expects(:send_template).once
    @sam_pseudo = create(:account, email: "sam@example.com", password: nil, status: Account::STATUS_PSEUDO)
  end

  test "users can login and get access tokens" do
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
    assert_equal Account::STATUS_REAL, json_response['status']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
  end

  test "deleted accounts cannot login" do
    @joe_real.delete!
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :unauthorized

    @joe_real.undelete!

    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
  end

  test "access tokens expire after 24 hours" do
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
    assert_equal Account::STATUS_REAL, json_response['status']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']

    travel 8.hours do
      get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
      assert_response :success
    end

    travel 25.hours do
      get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
      assert_response 401
    end
  end

  test "refresh tokens can be used to get new access tokens" do
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
    assert_equal Account::STATUS_REAL, json_response['status']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']

    travel 25.hours do
      get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
      assert_response 401

      post "/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response :success
      assert_equal @joe_real.email, json_response['email']
      new_token = json_response['meta']['access_token']

      get "/v1/accounts/#{@joe_real.id}", params: {access_token: new_token}
      assert_response :success
    end
  end

  test "after a password change, refresh tokens no longer work" do
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    put "/v1/accounts/#{@joe_real.id}", params: {access_token: token, password: 'abc', password_confirmation: 'abc'}
    assert_response :success

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response 401
  end

  test "refresh tokens expire after 2 years" do
    post "/v1/auth/login", params: {email: @joe_real.email, password: "j03"}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']
    token = json_response['meta']['access_token']
    refresh_token = json_response['meta']['refresh_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal @joe_real.email, json_response['email']

    post "/v1/auth/token", params: {refresh_token: refresh_token}
    assert_response :success

    travel 800.days do
      post "/v1/auth/token", params: {refresh_token: refresh_token}
      assert_response 401
    end
  end

  test "a new pseudo account can be created for a previously unseen email address" do
    captured_validation_link = nil
    MailTools.expects(:send_template).with {|email, template, params|
      captured_validation_link = params[:validation_link]
      email == "new@example.com" && params[:email_address] == "new@example.com" \
      && params[:validation_link] =~ /\/v1\/auth\/login\?email=new@example\.com/
    }

    post "/v1/auth/login", params: {email: "new@example.com"}
    assert_response :success
    assert_equal "new@example.com", json_response['email']
    assert_equal Account::STATUS_PSEUDO, json_response['status']
    id = json_response['id']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{id}", params: {access_token: token}
    assert_response :success
    assert_equal "new@example.com", json_response['email']
    assert_equal Account::STATUS_PSEUDO, json_response['status']

    post captured_validation_link.gsub('https://api.kithward.com', '')
    assert_response :success
    assert_equal "new@example.com", json_response['email']
    assert_equal Account::STATUS_REAL, json_response['status']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{id}", params: {access_token: token}
    assert_response :success
    assert_equal "new@example.com", json_response['email']
    assert_equal Account::STATUS_REAL, json_response['status']
  end

  test "an email-only authentication attempt will fail if there is an existing account with that email address" do
    post "/v1/auth/login", params: {email: @joe_real.email}
    assert_response :unauthorized
    assert_match(/Password/, json_response['errors'][0])

    post "/v1/auth/login", params: {email: @sam_pseudo.email}
    assert_response :unauthorized
    assert_match(/Verification/, json_response['errors'][0])
  end

  test "accounts can request a new verification email" do
    captured_validation_link = nil
    MailTools.expects(:send_template).with {|email, template, params|
      captured_validation_link = params[:validation_link]
      email == "joe@example.com" && params[:email_address] == "joe@example.com" \
      && params[:validation_link] =~ /\/v1\/auth\/login\?email=joe@example\.com/
    }

    post "/v1/auth/request_verification", params: {email: "joe@example.com"}
    assert_response :success

    post captured_validation_link.gsub('https://api.kithward.com', '')
    assert_response :success
    assert_equal "joe@example.com", json_response['email']
    token = json_response['meta']['access_token']

    get "/v1/accounts/#{@joe_real.id}", params: {access_token: token}
    assert_response :success
    assert_equal "joe@example.com", json_response['email']
  end
end
