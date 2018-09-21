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

    assert_equal "Main Building", json_response['caption']
    assert_equal "outside", json_response['tags']

    get "/v1/communities/#{@f1.id}/images"
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
  end

  test "admin users can add base64-encoded images on the community object endpoint" do
    encoded_image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAABxVBMVEUAAAAAoYwTl37FQAAAnYXEPQCW2ePRYQqV2eOX2uQAoYwAoYwAoYwAoYwAoYwAoYwAoYwAoYwBoYsjkHMAoYwMm4OEYC7/GQChUhnKPgDFQADHPwDFQAAAmoEAoIoAoIujURjFQADFPwDDOwCZ2+UrsaUcrJwTqJYEoYoDoYsWmX6qVBbHRwHGQQ+wAMyN1t6K1dyF09gZnXscnn0Ro4V5fkLNYAvBJVG5BnmV2eOW2eOW2ePRYQrRYQq8D3G8EG+V2eOV2ePRYgi8EG+T2+eV2uWX2uTTaAHNUR23mW5vpaJHrL42orYDhJ4Ah546YZ+uHX7lXACyZR7QYQvUYQjRYQrRYQq8EHC9EG1Db3+uEI+/EGcAoYwAoY0PmYEPmoGjURgAoIsAoYsPmoLHPwAbq5wcq5zJRQHHRgKK1d2L1d3QXwnQYAjNURuW2ePRYgnOVBrBIlmV2eO8D3CX2uTBI1i8EG9HrL5IrL9AeHAAg54Bg50Cg50DhJ4BhZ4bcaN4K7adD7ivEI67ZRpAenIBhJ8ccaN6KbWdD7ybEL2dELjTYQhBeXEdcKObELyvEI3RYQrUYQi3ZhxzLradDryeELb///8IFbyqAAAAXHRSTlMAAAAAAAAAAAAAC5OIBwmF+fZ5Bob2eQb1egb2egmF+f72egYDffnt09PW9vZ0Ag/HoxMUEyXVxg8QyJsT0sgQyJvSyBDImxPSEMf+0IiIkekQxxDIEMjHEP7HEPKh8/gAAAABYktHRJaRaSs5AAAAB3RJTUUH4gYYEDEr+3LHewAAAOVJREFUGNNjYAABRi5uHl5GBjhg5OMXEBQSZkLwRQRiYkTFxJmR+bFxEpJSzAh+TGx8grQMSIRFVk4+MQkokKyQoqikzMqgoqqWmqauoaGppZ2eoaOrx6BvkJmVZWhkbGJqlp2Ta27BYGmVl5dnzcbGbmObX1BoZ89g6VBUVOTIwcFu41RQWOxsz+DiWlJS4sbJye7uUVpcBhTw9Cr3rvDx9fXzDyguAwkEBlVWVdfU1tU3NDaBBYJDmltaa+va2js6u5pAAqFh3c09db3tHX19nV394RFAgQkTJ0VOntIHBJ1To6IB4YlDAOagaLIAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTgtMDYtMjRUMTY6NDk6NDMrMDI6MDAwZhSTAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE4LTA2LTI0VDE2OjQ5OjQzKzAyOjAwQTusLwAAAFd6VFh0UmF3IHByb2ZpbGUgdHlwZSBpcHRjAAB4nOPyDAhxVigoyk/LzEnlUgADIwsuYwsTIxNLkxQDEyBEgDTDZAMjs1Qgy9jUyMTMxBzEB8uASKBKLgDqFxF08kI1lQAAAABJRU5ErkJggg=="

    put "/v1/communities/#{@f1.id}", params: {access_token: @admin_token,
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
