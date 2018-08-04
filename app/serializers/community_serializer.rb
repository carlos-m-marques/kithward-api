# == Schema Information
#
# Table name: communities
#
#  id          :bigint(8)        not null, primary key
#  name        :string(1024)
#  description :text
#  street      :string(1024)
#  street_more :string(1024)
#  city        :string(256)
#  state       :string(128)
#  postal      :string(32)
#  country     :string(64)
#  lat         :float
#  lon         :float
#  data        :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  care_type   :string(1)        default("?")
#

class CommunitySerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :description,
    :care_type,
    :street, :street_more, :city, :state, :postal, :country,
    :lat, :lon,
    :data,
    :updated_at

  attribute :images do |object|
    object.community_images.collect do |image|
      {
        url: "/v1/communities/#{object.id}/images/#{image.id}",
        caption: image.caption,
        tags: image.tags,
      }
    end
  end
end
