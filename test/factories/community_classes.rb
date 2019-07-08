# == Schema Information
#
# Table name: community_classes
#
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  priority         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_care_type_il? :boolean          default(FALSE), not null
#  is_care_type_al? :boolean          default(FALSE), not null
#  is_care_type_sn? :boolean          default(FALSE), not null
#  is_care_type_mc? :boolean          default(FALSE), not null
#  is_care_type_un? :boolean          default(FALSE), not null
#

FactoryBot.define do
  factory :community_class do
    
  end
end
