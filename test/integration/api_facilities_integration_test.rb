require 'test_helper'

class ApiFacilitiesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Facility.delete_all

    @test_facility = Facility.create(name: "Test facility")
  end

  test "retrieve all" do
    get "/api/facilities"
    assert_response :success

    assert_equal @test_facility.id.to_s, json_response['data'][0]['id']
  end

  test "retrieve one" do
    get "/api/facilities/#{@test_facility.id}"
    assert_response :success

    assert_equal @test_facility.id.to_s, json_response['data']['id']
  end
end
