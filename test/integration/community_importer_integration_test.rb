require 'test_helper'

class CommunityImporterIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @c1 = create(:community, name: 'Golden Pond', description: 'Excelent Care', care_type: 'A')
    @c2 = create(:community, name: 'Silver Lining', description: 'Incredible Care', care_type: 'I')
    @c3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'A')
    @c4 = create(:community, name: 'Deleted Community', description: 'Useless Service', status: Community::STATUS_DELETED)

    @account = create(:account)
    @admin_account = create(:account, is_admin: true)

    @token = JsonWebToken.access_token_for_account(@account)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  test "basic endpoint access control" do
    post "/v1/communities/import"
    assert_response 401 # unauthorized

    post "/v1/communities/import", params: {access_token: @token}
    assert_response 401 # unauthorized

    post "/v1/communities/import", params: {access_token: @admin_token}
    assert_response :success

    assert_equal [], json_response['entries']
    assert_equal [{'message' => "No data!"}], json_response['errors']
  end

end
