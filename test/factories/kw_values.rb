# == Schema Information
#
# Table name: kw_values
#
#  id              :bigint(8)        not null, primary key
#  kw_attribute_id :bigint(8)
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kw_values_on_kw_attribute_id  (kw_attribute_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_attribute_id => kw_attributes.id)
#

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
