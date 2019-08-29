class CommunityImage < ApplicationRecord
  belongs_to :community

  default_scope { order(sort_order: :asc, id: :asc) }

  scope :has_image, -> { joins(image_attachment: :blob) }
  scope :published, -> { where(published: true) }

  has_one_attached :image

  after_save { community&.update_cached_image_url! }

  validates :image, attached: true

  # Account tie-in
  has_one :owner, through: :community
  has_many :accounts, through: :owner

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
