require 'test_helper'

class CommunityTest < ActiveSupport::TestCase
  setup do
  end

  test "Addresses are geocoded automatically" do
    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.add_stub(
      "123 Broadway, New York, NY, 10001, USA", [
        {
          'latitude'     => 40.75,
          'longitude'    => -74.00,
          'address'      => '123 Broadway',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    community = Community.create(name: "Broadway Care", street: "123 Broadway", city: "New York", state: "NY", postal: "10001", country: "USA")

    assert_equal(40.75, community.lat)
    assert_equal(-74.00, community.lon)
  end

  test "When a community gets some related communities, it caches their data" do
    community_1 = Community.create(name: "Broadway Care IL", care_type: Community::TYPE_INDEPENDENT, status: Community::STATUS_ACTIVE)
    community_2 = Community.create(name: "Broadway Care AL", care_type: Community::TYPE_ASSISTED, status: Community::STATUS_DELETED)
    community_3 = Community.create(name: "Broadway Care Too", care_type: Community::TYPE_INDEPENDENT, status: Community::STATUS_DRAFT)

    community_1.data['related_communities'] = [community_2.id, -community_3.id].join(",")
    community_1.save

    assert_equal [
      {'id' => community_2.id, 'name' => community_2.name, 'care_type' => community_2.care_type, 'status' => community_2.status, 'slug' => community_2.slug, 'related' => true},
      {'id' => community_3.id, 'name' => community_3.name, 'care_type' => community_3.care_type, 'status' => community_3.status, 'slug' => community_3.slug, 'similar' => true},
    ], community_1.data['related_community_data']

  end

  test "When data is changed, some of it gets cached in a separate field" do
    community = Community.create(status: Community::STATUS_ACTIVE, name: "Broadway Care IL", care_type: Community::TYPE_INDEPENDENT)
    community.data['star_rating'] = 4
    community.data['ccrc'] = true
    community.data['provider'] = 'Acme Inc'
    community.save

    assert_equal 4, community.data['star_rating']
    assert_equal 4, community.cached_data['star_rating']
    assert_equal true, community.data['ccrc']
    assert_equal true, community.cached_data['ccrc']
    assert_equal 'Acme Inc', community.data['provider']
    assert_nil community.cached_data['provider']
  end

  test "When listings are updated, their attributes are reflected in the containing community" do
    community = Community.create(status: Community::STATUS_ACTIVE, name: "Broadway Care IL", care_type: Community::TYPE_INDEPENDENT)
    listing_1 = community.listings.create(status: Listing::STATUS_ACTIVE, name: "1 Bedroom", data: {unit_type: 'room', bedrooms: '1', base_rent: '1000', room_feat_parking: true })
    listing_2 = community.listings.create(status: Listing::STATUS_ACTIVE, name: "2 Bedrooms", data: {unit_type: 'room', bedrooms: '2', base_rent: '1500:1800', room_feat_dishwasher: true })

    community.update_reflected_attributes_from_listings
    community.reload

    assert_equal "1,2", community.data['listings_bedrooms']
    assert_equal "1000:1800", community.data['listings_base_rent']
    assert_equal true, community.data['listings_room_feat_parking']

    listing_1.data['base_rent'] = '800:1200'
    listing_1.data.delete('room_feat_parking')
    listing_1.save
    community.update_reflected_attributes_from_listings
    community.reload

    assert_equal "800:1800", community.data['listings_base_rent']
    assert_nil community.data['listings_room_feat_parking']

    listing_2.data['base_rent'] = '1000:1300'
    listing_2.save
    community.update_reflected_attributes_from_listings
    community.reload

    assert_equal "800:1300", community.data['listings_base_rent']
  end
end
