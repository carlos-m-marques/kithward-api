require 'test_helper'

class GeoPlaceIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @g1 = create(:geo_place, name: '10011', full_name: '10011 - New York, NY')
    @g2 = create(:geo_place, name: '10012', full_name: '10012 - New York, NY')
    @g3 = create(:geo_place, name: '07094', full_name: '07094 - Secaucus, NJ')
  end

  test "search geo places" do
    GeoPlace.reindex

    get "/v1/geo_places", params: {q: '100'}
    assert_response :success
    assert_equal [@g1.id.to_s, @g2.id.to_s], json_response['data'].collect {|result| result['id']}
    assert_equal [@g1.name, @g2.name], json_response['data'].collect {|result| result['attributes']['name']}
  end

  test "retrieve geo place" do
    get "/v1/geo_places/#{@g2.id}"
    assert_response :success
    assert_equal @g2.id.to_s, json_response['data']['id']
  end
end
