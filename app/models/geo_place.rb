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
        state: state,
        location: {lat: lat, lon: lon},
        weight: weight,
      }
    end
  end

  def slug
    "#{full_name&.parameterize}-#{id}"
  end
end
