class Poi < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :poi_category
  has_and_belongs_to_many :communities

  scope :recent, -> { order(created_at: :desc) }
  scope :recently_updated, -> { order(updated_at: :desc) }
  scope :by_column, ->(column = :created_at, direction = :desc) { order(column => direction) }

  searchkick  match: :word_start,
              word_start:  ['name', 'street'],
              default_fields: ['name', 'street'],
              locations: ['location'],
              callbacks: :async

  def search_data
    {
      name: name,
      category: poi_category.name,
      street: street,
      city: city,
      state: state,
      postal: postal,
      country: country,
      location: { lat: lat, lon: lon }
    }
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
