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
#  old_data    :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  care_type   :string(1)        default("?")
#  status      :string(1)        default("?")
#  data        :jsonb
#

class Community < ApplicationRecord
  has_paper_trail

  has_many :community_images

  STATUS_ACTIVE    = 'A'
  STATUS_DRAFT     = '?'
  STATUS_DELETED   = 'X'

  TYPE_UNKNOWN     = '?'
  TYPE_INDEPENDENT = 'I'
  TYPE_ASSISTED    = 'A'
  TYPE_NURSING     = 'N'
  TYPE_MEMORY      = 'M'
  TYPE_HOSPICE     = 'H'
  TYPE_RESPITE     = 'R'

  SLUG_FOR_TYPE = {
    TYPE_INDEPENDENT: '-independent-living',
    TYPE_ASSISTED: '-assisted-living',
    TYPE_NURSING: '-skilled-nursing',
    TYPE_MEMORY: '-memory-care',
    TYPE_HOSPICE: '-hospice-care',
    TYPE_RESPITE: '-respite-care',
  }

  begin # attributes
    serialize :old_data, Hash
  end

  begin # Elasticsearch / Searchkick
    searchkick  match: :word_start,
                word_start:  ['name', 'description'],
                default_fields: ['name', 'description'],
                locations: ['location']

    def search_data
      {
        name: name,
        description: description,
        care_type: care_type,
        status: status,
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
      [street, city, state, postal, country].compact.join(', ')
    end

    def address_changed?
      street_changed? or city_changed? or state_changed? or postal_changed? or country_changed?
    end

    def address_complete?
      street.present? and ((city.present? and state.present?) or postal.present?)
    end
  end

  def slug
    "#{name.parameterize}#{SLUG_FOR_TYPE[care_type]}-#{id}"
  end

  def is_active?
    status == STATUS_ACTIVE
  end

  def is_draft?
    status == STATUS_DRAFT
  end

  def is_deleted?
    status == STATUS_DELETED
  end

  def not_active?
    status != STATUS_ACTIVE
  end
end
