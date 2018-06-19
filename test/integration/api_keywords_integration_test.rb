require 'test_helper'

class ApiKeywordsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Keyword.delete_all
    KeywordGroup.delete_all

    @kw_group_alpha = KeywordGroup.create(name: 'alpha', label: "Alpha Keywords")
    @kw_group_beta = KeywordGroup.create(name: 'beta', label: "Beta Keywords")

    @kw_red = Keyword.create(name: 'red', label: 'Red', keyword_group: @kw_group_alpha)
    @kw_blue = Keyword.create(name: 'blue', label: 'Blue', keyword_group: @kw_group_alpha)
    @kw_green = Keyword.create(name: 'green', label: 'Green', keyword_group: @kw_group_beta)
  end

  test "retrieve all" do
    get "/api/keywords"
    assert_response :success

    assert_equal ['red', 'blue', 'green'], json_response['data'].collect {|kw| kw['attributes']['name']}
    assert_equal ['Red', 'Blue', 'Green'], json_response['data'].collect {|kw| kw['attributes']['label']}
    assert_equal [@kw_group_alpha.id.to_s, @kw_group_alpha.id.to_s, @kw_group_beta.id.to_s], json_response['data'].collect {|kw| kw['relationships']['keyword_group']['data']['id']}
  end
end
