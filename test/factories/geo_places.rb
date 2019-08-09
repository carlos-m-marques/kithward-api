FactoryBot.define do
  sequence :geo_place_name do |n|
    "Geo Place \##{n}"
  end

  factory :geo_place do
    name { generate :geo_place_name }
    state { 'NY' }
    full_name { "#{name}, #{state}" }
  end
end
