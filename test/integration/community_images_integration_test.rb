require 'test_helper'
require 'digest'

class CommunityImagesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Community.delete_all

    @c1 = create(:community, name: 'Golden Pond', description: 'Excelent Care')

    @admin_account = create(:account, is_admin: true)
    @admin_token = JsonWebToken.access_token_for_account(@admin_account)
  end

  teardown do
  end

  test "admin users can add images to communities" do
    post "/v1/communities/#{@c1.id}/images", params: {access_token: @admin_token,
      caption: "Main Building", tags: "outside",
      image: fixture_file_upload("photo.jpg", "image/jpeg")
    }
    assert_response :success

    assert_equal "Main Building", json_response['caption']
    assert_equal "outside", json_response['tags']

    get "/v1/communities/#{@c1.id}/images"
    assert_response :success

    assert_equal "Main Building", json_response[0]['caption']
    assert_equal "outside", json_response[0]['tags']

    url = json_response[0]['url']

    get url
    assert_response :redirect
    second_url = response.location.gsub("http://www.example.com", "")

    get second_url
    assert_response :redirect
    third_url = response.location.gsub("http://www.example.com", "")

    get third_url
    assert_response :success
    assert_equal Digest::MD5.hexdigest(response.body), Digest::MD5.hexdigest(File.read('test/fixtures/photo.jpg'))

    get "/v1/communities/#{@c1.id}"
    assert_response :success
    assert_equal "Main Building", json_response['images'][0]['caption']
  end

  test "admin users can add base64-encoded images on the community object endpoint" do
    encoded_image = "data:image/png;base64,#{Base64.encode64(File.read('test/fixtures/favicon-16x16.png'))}"

    put "/v1/communities/#{@c1.id}", params: {access_token: @admin_token,
      name: "Golden Pond with logo",
      images: [
        {
          caption: "logo",
          tags: "outside",
          data: encoded_image
        }
      ]
    }
    assert_response :success

    assert_equal "Golden Pond with logo", json_response['name']
    assert_equal "logo", json_response['images'][0]['caption']
    assert_equal "outside", json_response['images'][0]['tags']

    url = json_response['images'][0]['url']

    get url
    assert_response :redirect
    second_url = response.location.gsub("http://www.example.com", "")

    get second_url
    assert_response :redirect
    third_url = response.location.gsub("http://www.example.com", "")


    get third_url
    assert_response :success
    assert_equal Digest::MD5.hexdigest(response.body), Digest::MD5.hexdigest(File.read('test/fixtures/favicon-16x16.png'))
  end
end
