class CommunitySerializer < Blueprinter::Base
  identifier :id

  view 'simple' do
    fields :status,
      :id,
      :name,
      :slug,
      :care_type,
      :street,
      :street_more,
      :postal,
      :township,
      :city, :county,
      :borough,
      :state,
      :metro,
      :region,
      :country,
      :lat,
      :lon,
      :updated_at,
      :units_available,
      :monthly_rent_lower_bound,
      :monthly_rent_upper_bound,
      :community_attributes,
      :cached_image_url
  end

  view 'complete' do
    include_view 'simple'

    field :description
    field :community_kw_values
    association :listings, blueprint: ListingSerializer
    association :community_images, name: :images, blueprint: CommunityImageSerializer
    association :pois, blueprint: PoiSerializer
  end

end
