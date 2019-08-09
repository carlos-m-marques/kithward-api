require 'test_helper'

class PoiCategoryTest < ActiveSupport::TestCase
  test "Category names have to be unique" do
    c1 = PoiCategory.create(name: "Restaurant")
    c2 = PoiCategory.create(name: "restaurant")
    
  end
end
