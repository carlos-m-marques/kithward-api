class ListingsImporterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(listing_id)
    listing = Listing.select(:id, :community_id, :name).find(listing_id)
    unit_layout = UnitType.create(name: listing.name, community_id: listing.community_id)

    listing.listing_images.joins(image_attachment: :blob).each do |listing_image|
      unit_layout_image = unit_layout.unit_type_images.new
      unit_layout_image.image.attach(listing_image.image.blob)

      unit_layout_image.save
    end

  end
end
