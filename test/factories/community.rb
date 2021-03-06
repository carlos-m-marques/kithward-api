FactoryBot.define do
  sequence :community_name do |n|
    "Community \##{n}"
  end

  factory :community do
    name { generate :community_name }
    description { "Lorem ipsum dolorem est" }
    status { Community::STATE_ACTIVE }
  end
end
