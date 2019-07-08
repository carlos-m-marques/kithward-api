# == Schema Information
#
# Table name: community_attribute_values
#
#  id                     :bigint(8)        not null, primary key
#  name                   :string           not null
#  priority               :integer          not null
#  community_attribute_id :bigint(8)        not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_community_attribute_values_on_community_attribute_id  (community_attribute_id)
#

class CommunityAttributeValue < ApplicationRecord
  belongs_to :community_attribute
  validates_presence_of :name, :priority
  has_and_belongs_to_many :communities
end
