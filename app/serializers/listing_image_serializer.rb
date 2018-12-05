# == Schema Information
#
# Table name: listing_images
#
#  id         :bigint(8)        not null, primary key
#  listing_id :bigint(8)
#  caption    :string(1024)
#  tags       :string(1024)
#  sort_order :integer          default(9999)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_images_on_listing_id  (listing_id)
#

class ListingImageSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :caption, :tags, :sort_order, :url, :content_type
end
