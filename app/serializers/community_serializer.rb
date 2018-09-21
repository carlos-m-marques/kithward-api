# == Schema Information
#
# Table name: communities
#
#  id               :bigint(8)        not null, primary key
#  name             :string(1024)
#  description      :text
#  street           :string(1024)
#  street_more      :string(1024)
#  city             :string(256)
#  state            :string(128)
#  postal           :string(32)
#  country          :string(64)
#  lat              :float
#  lon              :float
#  old_data         :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  care_type        :string(1)        default("?")
#  status           :string(1)        default("?")
#  data             :jsonb
#  cached_image_url :string(128)
#  cached_data      :jsonb
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
      :cached_image_url, :cached_data

  end

  view 'complete' do
    include_view 'simple'

    field :description
    field :data

    field :images do |object|
      object.community_images.sort_by {|i| [i.sort_order, i.id]}.collect do |image|
        {
          id: image.id,
          url: image.url,
          caption: image.caption,
          tags: image.tags,
          sort_order: image.sort_order,
          content_type: image.image.content_type,
        }
      end
    end
  end

end
