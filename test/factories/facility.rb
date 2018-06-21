FactoryBot.define do
  sequence :facility_name do |n|
    "Facility \##{n}"
  end

  factory :facility do
    name { generate :facility_name }
    description  "Lorem ipsum dolorem est"
  end
end
