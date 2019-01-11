# == Schema Information
#
# Table name: geo_places
#
#  id         :bigint(8)        not null, primary key
#  reference  :string(128)
#  geo_type   :string(10)
#  name       :string(255)
#  full_name  :string(255)
#  state      :string(128)
#  lat        :float
#  lon        :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :integer          default(0)
#

FactoryBot.define do
  sequence :geo_place_name do |n|
    "Geo Place \##{n}"
  end

  factory :geo_place do
    name { generate :geo_place_name }
    state { 'NY' }
    full_name { "#{name}, #{state}" }
  end
end
