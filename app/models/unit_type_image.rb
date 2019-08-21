class UnitTypeImage < ApplicationRecord
  belongs_to :unit_type

  default_scope { joins(image_attachment: :blob) }

  has_one_attached :image

  delegate :community_id, to: :unit_type

  validates :image, attached: true

  def file_url
    "/v1/admin/communities/#{community_id}/unit_layouts/#{unit_type_id}/unit_layout_images/#{id}/file"
  end

  def content_type
    image && image.attachment && image.attachment.content_type
  end
end
