FactoryBot.define do
  factory :kw_value do
    kw_attribute { nil }
    name { "MyString" }
    is_care_type_il { false }
    is_care_type_sn { false }
    is_care_type_mc { false }
    is_care_type_al { false }
    is_owner { false }
    is_community { false }
    is_building { false }
    is_unit { false }
    is_unit_type { false }
  end
end
