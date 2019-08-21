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
      exclude :cached_data

      field :description

      association :kw_values, blueprint: Admin::KwValueSerializer

      # association :listings, blueprint: ListingSerializer
      association :community_images, name: :images, blueprint: Admin::CommunityImageSerializer
      # association :pois, blueprint: PoiSerializer

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
end
