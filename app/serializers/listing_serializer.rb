# == Schema Information
#
# Table name: listings
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)
#  name         :string(1024)
#  status       :string(1)        default("?")
#  sort_order   :integer          default(9999)
#  data         :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_listings_on_community_id  (community_id)
#

class ListingSerializer < Blueprinter::Base
  identifier :id

  field :name
  field :status
  field :sort_order
  field :data

  association :listing_images, name: :images, blueprint: ListingImageSerializer
end
