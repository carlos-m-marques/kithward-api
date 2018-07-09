require 'test_helper'
require 'digest'

class CommunityImagesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Community.delete_all

    @f1 = create(:community, name: 'Golden Pond', description: 'Excelent Care')

    @admin_account = create(:account, is_admin: true)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  teardown do
  end

  test "admin users can add images to communities" do
    post "/v1/communities/#{@f1.id}/images", params: {access_token: @admin_token,
      caption: "Main Building", tags: "outside",
      image: fixture_file_upload("photo.jpg", "image/jpeg")
    }
    assert_response :success

    assert_equal "Main Building", json_response['data']['attributes']['caption']
    assert_equal "outside", json_response['data']['attributes']['tags']

    get "/v1/communities/#{@f1.id}/images"
    assert_response :success

    assert_equal "Main Building", json_response['data'][0]['attributes']['caption']
    assert_equal "outside", json_response['data'][0]['attributes']['tags']

    url = json_response['data'][0]['attributes']['url']

    get url
    assert_response :redirect
    second_url = response.location.gsub("http://www.example.com", "")

    get second_url
    assert_response :redirect
    third_url = response.location.gsub("http://www.example.com", "")


    get third_url
    assert_response :success
    assert_equal Digest::MD5.hexdigest(response.body), Digest::MD5.hexdigest(File.read('test/fixtures/photo.jpg'))
  end
end
