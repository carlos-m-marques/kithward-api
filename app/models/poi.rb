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

class Poi < ApplicationRecord
  has_paper_trail

  belongs_to :poi_category
  has_and_belongs_to_many :communities

  begin # Elasticsearch / Searchkick
    searchkick  match: :word_start,
                word_start:  ['name', 'street'],
                default_fields: ['name', 'street'],
                locations: ['location']

    def search_data
      {
        name: name,
        category: poi_category.name,
        street: street,
        city: city,
        state: state,
        postal: postal,
        country: country,
        location: {lat: lat, lon: lon},
      }
    end
  end

  begin # Geocoding
    geocoded_by :address, latitude: :lat, longitude: :lon
    after_validation :geocode, if: ->(obj){ obj.address_changed? and obj.address_complete? }

    def address
      [street, city, state, postal, country || 'USA'].compact.join(', ')
    end

    def address_changed?
      street_changed? or city_changed? or state_changed? or postal_changed? or country_changed?
    end

    def address_complete?
      street.present? and ((city.present? and state.present?) or postal.present?)
    end
  end

end
