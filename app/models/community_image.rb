class CommunityImage < ApplicationRecord
  #acts_as_paranoid

  scope :has_image, -> { joins(image_attachment: :blob) }
  scope :published, -> { where(published: true) }
  scope :with_tags, -> { where.not(tags: [nil, '']) }
  scope :all_tags, -> { with_tags.distinct(:tags).pluck(:tags).join(',').split(',').map(&:strip).uniq }

  validates :image, attached: true

  belongs_to :community
  has_one_attached :image
  has_one :owner, through: :community
  has_many :accounts, through: :owner

  delegate :name, to: :community, allow_nil: true

  # def all_tags
  #   CommunityImage.unscoped.distinct(:tags).pluck(:tags).map{ |tags| tags.split(',') if tags }.flatten.compact.uniq
  # end
  #
  # searchkick  match: :word_start,
  #         word_start:  ['caption'],
  #         default_fields: ['caption'],
  #         callbacks: :async
  #
  # def search_data
  #   attributes.merge({
  #     "id" => id,
  #     "url" => url,
  #     "content_type" => content_type
  #   })
  # end

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
