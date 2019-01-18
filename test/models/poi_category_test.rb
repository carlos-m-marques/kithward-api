# == Schema Information
#
# Table name: poi_categories
#
#  id   :bigint(8)        not null, primary key
#  name :string(128)
#

require 'test_helper'

class PoiCategoryTest < ActiveSupport::TestCase
  test "Category names have to be unique" do
    c1 = PoiCategory.create(name: "Restaurant")
    c2 = PoiCategory.create(name: "restaurant")
    
  end
end
