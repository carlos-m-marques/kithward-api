# == Schema Information
#
# Table name: communities
#
#  id                       :bigint(8)        not null, primary key
#  name                     :string(1024)
#  description              :text
#  street                   :string(1024)
#  street_more              :string(1024)
#  city                     :string(256)      not null
#  state                    :string(128)      not null
#  postal                   :string(32)       not null
#  country                  :string(64)       not null
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
#  owner_id                 :bigint(8)        not null
#  pm_system_id             :bigint(8)        not null
#  region                   :string           not null
#  metro                    :string
#  borough                  :string
#  county                   :string           not null
#  township                 :string
#
# Indexes
#
#  index_communities_on_owner_id      (owner_id)
#  index_communities_on_pm_system_id  (pm_system_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => owners.id)
#  fk_rails_...  (pm_system_id => pm_systems.id)
#

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

    association :super_classes, blueprint: KwSuperClassSerializer

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
