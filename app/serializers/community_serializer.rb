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

    field :favorited do |community, options|
      true
      # !!(options[:current_account_id] && community.favorited_by.select(:id).find_by(id: options[:current_account_id]).limit(1).present?)
    end
  end

  view 'complete' do
    include_view 'simple'

    field :description
    field :community_attributes
    association :community_images, name: :images, blueprint: CommunityImageSerializer
    association :pois, blueprint: PoiSerializer
    association :buildings, blueprint: Admin::BuildingSerializer
    association :units, blueprint: Admin::UnitTypeSerializer
    association :units_layouts, blueprint: Admin::UnitTypeSerializer
  end

end
