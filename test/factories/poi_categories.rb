FactoryBot.define do
  sequence :poi_category_name do |n|
    "POI Category \##{n}"
  end

  factory :poi_category do
    name { generate :poi_category_name }
  end
end
