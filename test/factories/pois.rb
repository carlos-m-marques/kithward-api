# == Schema Information
#
# Table name: pois
#
#  id              :bigint(8)        not null, primary key
#  name            :string(1024)
#  poi_category_id :bigint(8)
#  street          :string(1024)
#  city            :string(256)
#  state           :string(128)
#  postal          :string(32)
#  country         :string(64)
#  lat             :float
#  lon             :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :bigint(8)
#
# Indexes
#
#  index_pois_on_created_by_id    (created_by_id)
#  index_pois_on_poi_category_id  (poi_category_id)
#

FactoryBot.define do
  sequence :poi_name do |n|
    "Point Of Interest \##{n}"
  end

  factory :poi do
    name { generate :poi_name }
    association :poi_category
  end
end
