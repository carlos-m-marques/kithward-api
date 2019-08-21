class CommunityImage < ApplicationRecord
  belongs_to :community

  default_scope { order(sort_order: :asc, id: :asc) }

  scope :has_image, -> { joins(image_attachment: :blob) }

  has_one_attached :image

  after_save { community&.update_cached_image_url! }

  validates :image, attached: true

  def file_url
    "/v1/admin/communities/#{community_id}/community_images/#{id}/file"
  end

  def url
    "/v1/communities/#{self.community_id}/images/#{self.id}"
  end

  def content_type
    image and image.attachment and image.attachment.content_type
  end
end
