require 'test_helper'

class KeywordsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Keyword.delete_all
    KeywordGroup.delete_all

    @kw_group_alpha = create(:keyword_group, name: 'alpha')
    @kw_group_beta = create(:keyword_group, name: 'beta')

    @kw_red = create(:keyword, name: 'red', keyword_group: @kw_group_alpha)
    @kw_blue = create(:keyword, name: 'blue', keyword_group: @kw_group_alpha)
    @kw_green = create(:keyword, name: 'green', keyword_group: @kw_group_beta)
  end

  test "retrieve all" do
    get "/api/v1/keywords"
    assert_response :success

    assert_equal ['red', 'blue', 'green'], json_response['data'].collect {|kw| kw['attributes']['name']}
    assert_equal ['Red', 'Blue', 'Green'], json_response['data'].collect {|kw| kw['attributes']['label']}
    assert_equal [@kw_group_alpha.id.to_s, @kw_group_alpha.id.to_s, @kw_group_beta.id.to_s], json_response['data'].collect {|kw| kw['relationships']['keyword_group']['data']['id']}
  end
end
