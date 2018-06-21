require 'test_helper'

class FacilitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Facility.delete_all

    @f1 = create(:facility)
    @f2 = create(:facility)
    @f3 = create(:facility)
  end

  test "retrieve all" do
    get "/api/v1/facilities"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data'][0]['id']
    assert_equal @f2.id.to_s, json_response['data'][1]['id']
    assert_equal @f3.id.to_s, json_response['data'][2]['id']

    assert_equal @f1.name, json_response['data'][0]['attributes']['name']
    assert_equal @f2.name, json_response['data'][1]['attributes']['name']
    assert_equal @f3.name, json_response['data'][2]['attributes']['name']
  end

  test "retrieve one" do
    get "/api/v1/facilities/#{@f1.id}"
    assert_response :success

    assert_equal @f1.id.to_s, json_response['data']['id']
    assert_equal @f1.name, json_response['data']['attributes']['name']
  end
end
