FactoryBot.define do
  sequence :keyword_group_name do |n|
    "Keyword Group \##{n}"
  end

  factory :keyword_group do
    name { generate :keyword_group_name }
    label { name.titlecase }
  end
end
