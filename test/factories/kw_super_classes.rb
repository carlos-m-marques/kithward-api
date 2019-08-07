# == Schema Information
#
# Table name: kw_super_classes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type       :string
#  care_type  :string
#
# Indexes
#
#  index_kw_super_classes_on_care_type  (care_type)
#  index_kw_super_classes_on_type       (type)
#

FactoryBot.define do
  factory :kw_super_class do
    name { "MyString" }
    is_care_type_il? { false }
    is_care_type_sn? { false }
    is_care_type_mc? { false }
    is_care_type_al? { false }
    is_owner? { false }
    is_community? { false }
    is_building? { false }
    is_unit? { false }
    is_unit_type? { false }
  end
end
