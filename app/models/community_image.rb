class CommunityImage < ApplicationRecord
  belongs_to :community

  default_scope { order(sort_order: :asc, id: :asc) }

  has_one_attached :image

  after_save { community&.update_cached_image_url! }

  validates :image, attached: true

  def url
    "/v1/communities/#{self.community_id}/images/#{self.id}"
  end

  def content_type
    image and image.attachment and image.attachment.content_type
  end
end
