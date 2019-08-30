class UnitTypeImage < ApplicationRecord
  belongs_to :unit_type

  default_scope { joins(image_attachment: :blob) }
  scope :published, -> { where(published: true) }
  scope :with_tags, -> { where.not(tags: [nil, '']) }
  scope :all_tags, -> { unscoped.with_tags.distinct(:tags).pluck(:tags).join(',').split(',').map(&:strip).uniq }

  has_one_attached :image

  delegate :community_id, to: :unit_type

  validates :image, attached: true

  # Account tie-in
  has_one :owner, through: :unit_type
  has_many :accounts, through: :owner

  def file_url
    "/v1/admin/communities/#{community_id}/unit_layouts/#{unit_type_id}/unit_layout_images/#{id}/file"
  end

  def content_type
    image && image.attachment && image.attachment.content_type
  end
end
