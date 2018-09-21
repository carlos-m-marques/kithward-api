require 'test_helper'

class LeadsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Account.delete_all

    @account_a = create(:account)

    @token_a = JsonWebToken.access_token_for_account(@account_a)
  end

  test "anyone can start a lead" do
    post "/v1/leads", params: {name: "Joe", email: "joe@gmail.com", community_id: 123}
    assert_response :success

    assert_equal "Joe", json_response['name']
    assert_equal "joe@gmail.com", json_response['email']
    assert_equal 123, json_response['community_id']
  end

  test "logged in users can also start a lead" do
    post "/v1/leads", params: {name: "Sam", email: "sam@gmail.com", community_id: 456, access_token: @token_a}
    assert_response :success

    assert_equal "Sam", json_response['name']
    assert_equal "sam@gmail.com", json_response['email']
    assert_equal 456, json_response['community_id']
    assert_equal @account_a.id, json_response['account_id']
  end

end
