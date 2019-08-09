FactoryBot.define do
  sequence :poi_name do |n|
    "Point Of Interest \##{n}"
  end

  factory :poi do
    name { generate :poi_name }
    association :poi_category
  end
end
