# == Schema Information
#
# Table name: community_attributes
#
#  id                 :bigint(8)        not null, primary key
#  name               :string           not null
#  priority           :integer          not null
#  community_class_id :bigint(8)        not null
#  is_required        :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_community_attributes_on_community_class_id  (community_class_id)
#

FactoryBot.define do
  factory :community_attribute do
    
  end
end
