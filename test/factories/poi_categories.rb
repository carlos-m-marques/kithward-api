# == Schema Information
#
# Table name: poi_categories
#
#  id   :bigint(8)        not null, primary key
#  name :string(128)
#

FactoryBot.define do
  sequence :poi_category_name do |n|
    "POI Category \##{n}"
  end

  factory :poi_category do
    name { generate :poi_category_name }
  end
end
