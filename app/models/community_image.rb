# == Schema Information
#
# Table name: community_images
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)
#  caption      :string(1024)
#  tags         :string(1024)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sort_order   :integer          default(9999)
#
# Indexes
#
#  index_community_images_on_community_id  (community_id)
#

class CommunityImage < ApplicationRecord
  belongs_to :community

  has_one_attached :image

  after_save { community&.update_cached_image_url! }

  def url
    "/v1/communities/#{self.community_id}/images/#{self.id}"
  end
end
