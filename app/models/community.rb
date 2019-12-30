require 'hashdiff'

class Community < ApplicationRecord
  include Flaggable
  include AASM

  has_paper_trail
  #acts_as_paranoid

  after_commit :reindex_associations

  def reindex_associations
    # unit_layouts.reindex
    # buildings.reindex
    # units.reindex
    # pois.reindex
    listings.reindex
  end

  after_save :set_slug!

  has_many :communities, foreign_key: :community_id, class_name: 'RelatedCommunity'
  has_many :related_communities, through: :communities, source: :related_community

  has_many :unit_layouts, class_name: 'UnitType', dependent: :destroy
  has_many :buildings, dependent: :destroy
  has_many :units, through: :unit_layouts

  has_many :community_images, dependent: :destroy

  has_many :listings
  has_and_belongs_to_many :pois
  belongs_to :owner, optional: true
  belongs_to :pm_system, optional: true
  has_many :accounts, through: :owner

  has_many :community_share_hits

  has_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :community_super_classes, through: :kw_classes

  has_and_belongs_to_many :accounts, autosave: false
  alias_method :favorited_by, :accounts

  has_many :account_access_request_communities
  has_many :account_access_requests, through: :account_access_request_communities

  def community_kw_values
    all_hash = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] } }

    kw_values.includes({ kw_attribute: { kw_class: :kw_super_class } }).each do |kw_value|
      if all_hash[kw_value.kw_attribute.kw_class.kw_super_class.name][kw_value.kw_attribute.kw_class.name]
        if kw_value.kw_attribute.ui_type == 'boolean'
          all_hash[kw_value.kw_attribute.kw_class.kw_super_class.name][kw_value.kw_attribute.kw_class.name] << { kw_value.kw_attribute.name => 'Yes' }
        else
          all_hash[kw_value.kw_attribute.kw_class.kw_super_class.name][kw_value.kw_attribute.kw_class.name] << { kw_value.kw_attribute.name => kw_value.name }
        end
      else
        if kw_value.kw_attribute.ui_type == 'boolean'
          all_hash[kw_value.kw_attribute.kw_class.kw_super_class.name][kw_value.kw_attribute.kw_class.name] = [{ kw_value.kw_attribute.name => 'Yes' }]
        else
          all_hash[kw_value.kw_attribute.kw_class.kw_super_class.name][kw_value.kw_attribute.kw_class.name] = [{ kw_value.kw_attribute.name => kw_value.name }]
        end
      end
    end

    all_hash
  end


  begin
    unless ENV['SSI']
      searchkick  locations: [:location],
              inheritance: true,
              match: :word_start,
              word_start:  ['name', 'description'],
              default_fields: ['name', 'description'],
              callbacks: :async
    else
      searchkick match: :word,
             default_fields: ['id'],
             index_prefix: "simple",
             callbacks: :async
    end
  end

  def search_data
    unless ENV['SSI']
      attributes.except('data', 'cached_image_url', 'cached_data').merge({
        "id" => id,
        "slug" => slug,
        "location" => { lat: lat, lon: lon },
        # "buildings" => buildings,
        "cached_image_url" => image_url,
        # "unit_layouts" => unit_layouts,
        # "pois" => pois,
        "images" => community_images.published,
        # "units" => units,
        "listings" => listings,
        "community_attributes" => community_kw_values,
        "units_available" => units.available,
        "monthly_rent_lower_bound" => monthly_rent_lower_bound,
        "monthly_rent_upper_bound" => monthly_rent_upper_bound
      })
    else
      {
        'id' => id,
        'data' => data
      }
    end
  end

  def search_stuff
    {
      "data" => data,
      "id" => id
    }
  end

  # def community_attributes
  #   attrs = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] } } }
  #
  #   kw_values.includes(:kw_class, :kw_super_class, :kw_attribute).distinct.each do |value|
  #     next unless value.kw_attribute.visible?
  #
  #     attrs[value.kw_super_class.name][value.kw_class.name][value.kw_attribute.name] << value.name
  #   end
  #
  #   attrs
  # end

  aasm column: :status do
    state :draft, initial: true
    state :active

    event :active do
      transitions from: :pending, to: :active
    end
  end

  TYPE_UNKNOWN     = '?'
  TYPE_INDEPENDENT = 'I'
  TYPE_ASSISTED    = 'A'
  TYPE_NURSING     = 'N'
  TYPE_MEMORY      = 'M'

  CARE_TYPES = [
    TYPE_INDEPENDENT,
    TYPE_ASSISTED,
    TYPE_NURSING,
    TYPE_MEMORY
  ].freeze

  scope :with_images, -> { joins(community_images: { image_attachment: :blob }).distinct }
  scope :recent, -> { order(created_at: :desc) }
  scope :recently_updated, -> { order(updated_at: :desc) }
  scope :by_column, ->(column = :created_at, direction = :desc) { order(column => direction) }
  scope :with_pois, -> { joins(:pois).distinct }

  scope :care_type_il, -> { where(care_type: TYPE_INDEPENDENT) }
  scope :care_type_al, -> { where(care_type: TYPE_ASSISTED) }
  scope :care_type_sn, -> { where(care_type: TYPE_NURSING) }
  scope :care_type_mc, -> { where(care_type: TYPE_MEMORY_CARE) }

  scope :has_data_field, ->(field) { where('data ? :field', field: field) }
  scope :has_no_data_field, ->(field) { where('NOT(data ? :field)', field: field) }
  scope :has_one_of_data_fields, ->(fields) { where('data ?| :fields', field: fields) }
  scope :has_all_of_data_fields, ->(fields) { where('data ?& :fields', field: fields) }

  scope :units_available, -> { joins(:units).merge(Unit.available) }

  validates_presence_of :country, :region, :state, :county, :city, :postal, :name, :owner
  validates :care_type, inclusion: { in: Community::CARE_TYPES }

  TYPE_FOR_LABEL = {
    'Independent Living' => TYPE_INDEPENDENT,
    'Assisted Living' => TYPE_ASSISTED,
    'Skilled Nursing' => TYPE_NURSING,
    'Memory Care' => TYPE_MEMORY
  }

  SLUG_FOR_TYPE = {
    TYPE_INDEPENDENT => '-independent-living',
    TYPE_ASSISTED => '-assisted-living',
    TYPE_NURSING => '-skilled-nursing',
    TYPE_MEMORY => '-memory-care',
  }

  LABEL_FOR_TYPE = {
    TYPE_INDEPENDENT => 'Independent Living',
    TYPE_ASSISTED => 'Assisted Living',
    TYPE_NURSING => 'Skilled Nursing',
    TYPE_MEMORY => 'Memory Care',
  }

  PARAM_FOR_TYPE = {
    'independent' => 'I',
    'assisted' => 'A',
    'nursing' => 'N',
    'memory' => 'M'
  }

  def metro
    super || self.city
  end

  def borough
    super || self.city
  end

  def township
    super || self.city
  end

  def data
    self[:data] ||= {}
  end

  def care_type_label
    LABEL_FOR_TYPE[care_type]
  end

  def add_poi_ids=(ids)
    self.assign_attributes({poi_ids: (self.poi_ids + ids)})
  end

  def add_community_image_id=(ids)
    self.assign_attributes({community_image_ids: (self.community_image_id + ids)})
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

  def set_slug!
    self.update_column(:slug, "#{name&.parameterize}#{SLUG_FOR_TYPE[care_type]}-#{id}")
  end

  def units_available
    units.available.present?
  end

  def find_monthly_rent_lower_bound
    units.minimum(:rent_market) || monthly_rent_lower_bound
  end

  def find_monthly_rent_upper_bound
    units.maximum(:rent_market) || monthly_rent_upper_bound
  end

  def shared!(tracking:)
    CommunityShareHit.create(tracking: tracking)
  end

  ATTRIBUTES_TO_CACHE = [
    'star_rating', 'aip', 'ccrc',

    'listings_room_shared', 'listings_room_private', 'listings_room_studio', 'listings_room_one_bed', 'listings_room_two_plus', 'listings_room_detached',

    'listings_room_feat_den', 'listings_room_feat_dishwasher', 'listings_room_feat_kitchen', 'listings_room_feat_climate',
    'listings_room_feat_pvt_outdoor', 'listings_room_feat_walkin', 'listings_room_feat_washer',

    'access_to_city', 'access_to_outdoors', 'amenitiy_any_fitness', 'services_parking', 'amenity_any_pool',
    'food_restaurant_style', 'smoking',
    'amenitiy_gym', 'amenitiy_fitness_center', 'amenitiy_athletic_club',
    'amenity_indoor_pool', 'amenity_outdoor_pool',
    'completeness', 'needs_review', 'price_range'
  ]

  def image_url
    self.community_images.reload.select {|i| i.tags !~ /(floorplan|map|calendar)/ }.sort_by {|i| [i.sort_order, i.id]}.first.try(:url)
  end

  def update_cached_image_url!
    image = self.community_images.reload.select {|i| i.tags !~ /(floorplan|map|calendar)/ }.sort_by {|i| [i.sort_order, i.id]}.first
    if image
      self.update_attributes(cached_image_url: image.url)
    end
  end

  def update_reflected_attributes_from_listings
    attrs = DataDictionary::Listing.attributes

    reflection = {}
    attrs.each do |key, attr_def|
      case attr_def && attr_def[:data]
      when 'select'
        reflection[key] = []
      when 'pricerange', 'numberrange'
        reflection[key] = [nil, nil]
      when 'price', 'number'
        reflection[key] = [nil, nil]
      when 'amenity', 'flag'
        reflection[key] = false
      end
    end

    listings.active_or_hidden.each do |listing|
      (listing.data || {}).each do |key, value|
        case attrs[key] && attrs[key][:data]
        when 'select'
          values = value.split(/\s*,\s*/)
          reflection[key] = (reflection[key] + [values]).flatten.uniq

          if key.to_s == 'bedrooms'
            case value
            when 'Shared'
              reflection['room_shared'] = true
            when 'Suite'
              reflection['room_companion'] = true
            when 'Studio'
              reflection['room_studio'] = true
            when '1'
              reflection['room_one_bed'] = true
            when '2'
              reflection['room_two_plus'] = true
            when '3'
              reflection['room_two_plus'] = true
            when '4+'
              reflection['room_two_plus'] = true
            end
          end

        when 'pricerange', 'numberrange'
          values = "#{value}".split(":").collect {|p| p.to_i}
          if values.first
            reflection[key][0] = [reflection[key].first || values.first, values.first].min
          end
          if values.last
            reflection[key][1] = [reflection[key].last || values.last, values.last].max
          end
        when 'price', 'number'
          value = value.to_i
          if value
            reflection[key][0] = [reflection[key].first || value, value].min
          end
          if value
            reflection[key][1] = [reflection[key].last || value, value].max
          end

        when 'amenity', 'flag'
          reflection[key] = reflection[key] || value
        end

      end
    end

    attrs.each do |key, attr_def|
      case attr_def && attr_def[:data]
      when 'select'
        if reflection[key].any?
          self.data["listings_#{key}"] = reflection[key].join(",")
        else
          self.data.delete("listings_#{key}")
        end

        if key.to_s == 'bedrooms'
          ['room_shared', 'room_companion', 'room_studio', 'room_one_bed', 'room_two_plus'].each do |room_key|
            if reflection[room_key]
              self.data["listings_#{room_key}"] = true
            else
              self.data.delete("listings_#{room_key}")
            end
          end
        end

      when 'pricerange', 'numberrange', 'price', 'number'
        if reflection[key].compact.any?
          self.data["listings_#{key}"] = reflection[key][0..1].join(":")
        else
          self.data.delete("listings_#{key}")
        end
      when 'amenity', 'flag'
        if reflection[key]
          self.data["listings_#{key}"] = true
        else
          self.data.delete("listings_#{key}")
        end
      end
    end

    self.save
  end

  def self.rename_data_attributes(map)
    Community.where('data ?| array[:keys]', keys: map.keys).find_each do |community|
      map.each do |key, new_key|
        community.data[new_key] = community.data[key]
        community.data.delete(key)
      end
      community.save
    end
  end
end
