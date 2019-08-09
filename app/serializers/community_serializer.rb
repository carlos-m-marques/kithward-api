class CommunitySerializer < Blueprinter::Base
  identifier :idstr, name: :id

  view 'simple' do
    fields :status,
      :name,
      :slug,
      :care_type,
      :street, :street_more, :postal, :township, :city, :county, :borough, :state, :metro, :region, :country,
      :lat, :lon,
      :updated_at,
      :cached_image_url, :cached_data,
      :units_available,
      :monthly_rent_lower_bound,
      :monthly_rent_upper_bound
  end

  view 'complete' do
    include_view 'simple'
    exclude :cached_data

    field :description
    field :data

    # association :super_classes, blueprint: KwSuperClassSerializer

    association :listings, blueprint: ListingSerializer
    association :community_images, name: :images, blueprint: CommunityImageSerializer
    association :pois, blueprint: PoiSerializer

    # field :images do |object|
    #   object.community_images.sort_by {|i| [i.sort_order, i.id]}.collect do |image|
    #     {
    #       id: image.id,
    #       url: image.url,
    #       caption: image.caption,
    #       tags: image.tags,
    #       sort_order: image.sort_order,
    #       content_type: image.image.content_type,
    #     }
    #   end
    # end
  end

end
