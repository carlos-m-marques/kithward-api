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
#

class GeoPlace < ApplicationRecord
  TYPE_POSTAL = 'postal'
  TYPE_GEONAME = 'geoname'

  begin # Elasticsearch / Searchkick
    searchkick  match: :word_start,
                word_start:  ['name'],
                default_fields: ['name'],
                locations: ['location']

    def search_data
      {
        name: name,
        location: {lat: lat, lon: lon},
      }
    end
  end
end
