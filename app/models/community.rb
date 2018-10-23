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
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  care_type        :string(1)        default("?")
#  status           :string(1)        default("?")
#  data             :jsonb
#  cached_image_url :string(128)
#  cached_data      :jsonb
#

require 'hashdiff'

class Community < ApplicationRecord
  has_paper_trail

  has_many :community_images
  has_many :listings

  before_save :update_cached_data

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

  def data
    self[:data] ||= {}
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

  begin # Data manipulation
    scope :with_data, ->(name, value = nil) do
      if value
        where("communities.data @> :json", :json => {name.to_sym => value}.to_json)
      else
        where("communities.data ? :attr_name", {attr_name: name})
      end
    end

    scope :with_any_of_data, ->(*names) do
      where("communities.data ?| array[:names]", :names => names.flatten)
    end

    scope :with_all_of_data, ->(*names) do
      where("communities.data ?& array[:names]", :names => names.flatten)
    end

    def rename_data(from, to)
      if self.data[from.to_s]
        self.data[to.to_s] = self.data[from.to_s]
        self.data.delete(from.to_s)
      end
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
    "#{name&.parameterize}#{SLUG_FOR_TYPE[care_type]}-#{id}"
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

  ATTRIBUTES_TO_CACHE = [
    'star_rating', 'aip', 'ccrc',
    'room_shared', 'room_private', 'room_studio', 'room_one_bed', 'room_two_plus', 'room_detached',
    'room_feat_den', 'room_feat_dishwasher', 'room_feat_kitchen', 'room_feat_climate',
    'room_feat_pvt_outdoor', 'room_feat_walkin', 'room_feat_washer',
    'access_to_city', 'access_to_outdoors', 'amenitiy_any_fitness', 'services_parking', 'amenity_any_pool',
    'food_restaurant_style', 'smoking',
    'assistance_any_day_to_day', 'staff_doctors_ft', 'staff_nurses_ft', 'care_incontinence',
    'assistance_medication', 'care_dementia', 'care_occupational', 'care_physical',
    'care_speech', 'care_any_visiting_specialists',
    'amenitiy_gym', 'amenitiy_fitness_center', 'amenitiy_athletic_club',
    'amenity_indoor_pool', 'amenity_outdoor_pool',
    'assistance_bathing', 'assistance_dressing', 'assistance_errands', 'assistance_grooming',
    'assistance_mobility', 'assistance_toileting',
    'care_onsite_audiologist', 'care_onsite_cardiologist', 'care_onsite_dentist',
    'care_onsite_dermatologist', 'care_onsite_dietician', 'care_onsite_endocronologist',
    'care_onsite_internist', 'care_onsite_neurologist', 'care_onsite_opthamologist',
    'care_onsite_optometrist', 'care_onsite_podiatrist', 'care_onsite_pulmonologist',
    'care_onsite_psychologist', 'care_onsite_psychiatrist', 'care_onsite_urologist',
  ]

  def update_cached_data
    # WARNING: This subset of keys should reflect what's on web/src/tools/KWConsts.js#CRITERIA_SPEC

    if data_changed?
      diff = HashDiff.diff(self.data_was || {}, self.data || {})
      changed_attributes = diff.collect {|change, name, value| name}

      if (changed_attributes & ATTRIBUTES_TO_CACHE).any?
        self.cached_data = (self.data || {}).slice(ATTRIBUTES_TO_CACHE)
      end

      if changed_attributes.include? 'related_communities'
        ids = (self.data['related_communities'] || "").split(/\s*,\s*/)
        self.data['related_community_data'] = ids.collect do |id|
          id = id.to_i
          if c = Community.find(id.abs)
            row = {id: c.id, name: c.name, care_type: c.care_type, status: c.status, slug: c.slug}
            if id < 0
              row[:similar] = true
            else
              row[:related] = true
            end
          end
          row
        end
      end
    end

    return true
  end

  def update_cached_image_url!
    image = self.community_images.reload.sort_by {|i| [i.sort_order, i.id]}.first
    if image
      self.update_attributes(cached_image_url: image.url)
    end
  end
end
