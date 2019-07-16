# == Schema Information
#
# Table name: kw_super_classes
#
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  is_care_type_il? :boolean          default(FALSE), not null
#  is_care_type_sn? :boolean          default(FALSE), not null
#  is_care_type_mc? :boolean          default(FALSE), not null
#  is_care_type_al? :boolean          default(FALSE), not null
#  is_owner?        :boolean          default(FALSE), not null
#  is_community?    :boolean          default(FALSE), not null
#  is_building?     :boolean          default(FALSE), not null
#  is_unit?         :boolean          default(FALSE), not null
#  is_unit_type?    :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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
