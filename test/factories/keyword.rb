FactoryBot.define do
  sequence :keyword_name do |n|
    "Keyword \##{n}"
  end

  factory :keyword do
    name { generate :keyword_name }
    label { name.titlecase }

    keyword_group
  end
end
