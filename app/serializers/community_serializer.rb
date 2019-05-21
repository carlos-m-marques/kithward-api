# == Schema Information
#
# Table name: communities
#
#  id                       :bigint(8)        not null, primary key
#  name                     :string(1024)
#  description              :text
#  street                   :string(1024)
#  street_more              :string(1024)
#  city                     :string(256)
#  state                    :string(128)
#  postal                   :string(32)
#  country                  :string(64)
#  lat                      :float
#  lon                      :float
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  care_type                :string(1)        default("?")
#  status                   :string(1)        default("?")
#  data                     :jsonb
#  cached_image_url         :string(128)
#  cached_data              :jsonb
#  monthly_rent_lower_bound :float
#  monthly_rent_upper_bound :float
#

class CommunitySerializer < Blueprinter::Base
  identifier :idstr, name: :id

  view 'simple' do
    fields :status,
      :name,
      :slug,
      :care_type,
      :street, :street_more, :city, :state, :postal, :country,
      :lat, :lon,
      :updated_at,
      :cached_image_url, :cached_data,
      :units_available,
      :monthly_rent_lower_bound
  end

  view 'complete' do
    include_view 'simple'
    exclude :cached_data

    field :description
    field :data

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
