class ListingSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  field :name
  field :status
  field :sort_order
  field :data

  association :listing_images, name: :images, blueprint: ListingImageSerializer
end
