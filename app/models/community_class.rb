# == Schema Information
#
# Table name: community_classes
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  priority    :integer
#  is_required :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CommunityClass < ApplicationRecord
  has_many :community_attributes

  validates_presence_of :name
end
