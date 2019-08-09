class ListingImage < ApplicationRecord
  belongs_to :listing

  default_scope { order(sort_order: :asc, id: :asc) }

  has_one_attached :image

  def url
    "/v1/listings/#{self.listing_id}/images/#{self.id}"
  end

  def content_type
    image and image.attachment and image.attachment.content_type
  end
end
