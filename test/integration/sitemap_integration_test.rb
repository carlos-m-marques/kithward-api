require 'test_helper'

class SitemapIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @c1 = create(:community, name: 'Golden Pond', description: 'Excelent Care', care_type: 'A')
    @c2 = create(:community, name: 'Silver Lining', description: 'Incredible Care', care_type: 'I')
    @c3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'I')
    @c4 = create(:community, name: 'Deleted Community', description: 'Useless Service', status: Community::STATUS_DELETED)
  end

  test "a sitemap is generated" do
    get "/sitemap.xml"
    assert_response :success

    assert response.body.include?("<loc>https://kithward.com/</loc>")
    assert response.body.include?("<loc>https://kithward.com/community/silver-lining-independent-living-#{@c2.id}</loc><lastmod>#{@c2.updated_at.strftime("%F")}</lastmod>")
    assert response.body.include?("<loc>https://kithward.com/community/gray-peaks-independent-living-#{@c3.id}</loc><lastmod>#{@c3.updated_at.strftime("%F")}</lastmod>")
  end

end
