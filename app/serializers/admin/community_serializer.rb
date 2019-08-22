module Admin
  class CommunitySerializer < Blueprinter::Base
    identifier :id

    view 'list' do
      field :flagged_at
      field :flagged_for

      fields :address,
        :care_type_label,
        :name,
        :city,
        :state,
        :postal,
        :owner_id
      field :postal, name: :zip
    end

    view 'simple' do
      field :flagged_at
      field :flagged_for

      fields :name,
        :slug,
        :care_type,
        :street, :street_more, :postal, :township, :city, :county, :borough, :state, :metro, :region, :country,
        :created_at,
        :updated_at,
        :owner_id
        # :status,
        # :lat, :lon,
        # :cached_image_url,
        # :cached_data
    end

    view 'complete' do
      include_view 'simple'

      field :description

      association :kw_values, blueprint: Admin::KwValueSerializer
      association :community_images, name: :images, blueprint: Admin::CommunityImageSerializer
      association :pois, blueprint: Admin::PoiSerializer
    end
  end
end
