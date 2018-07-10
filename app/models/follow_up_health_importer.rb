require 'pg'
require 'open-uri'

module FollowUpHealthImporter
  def self.import
    pg = PG.connect(ENV['FUH_DB'])
    facilities = pg.exec("
      SELECT
        f.facility_id as fuh_id, f.*, addr.*, prices.*
      FROM
        facilities f
        INNER JOIN addresses addr ON f.address_id = addr.address_id
        LEFT OUTER JOIN facility_prices prices ON prices.facility_id = f.facility_id
    ")
    facilities.each do |row|
      community = Community.find_or_create_by(street: row['street'], care_type: FACILITY_TYPE_VALUES[row['facility_type_id']])

      if community.data['fuh_facility_id'] && community.data['fuh_facility_id'] != row['fuh_id']
        # if there are multiple ids, keep a list
        community.data['fuh_facility_ids'] = [community.data['fuh_facility_ids'], community.data['fuh_facility_id'], row['fuh_id']].flatten.compact.uniq
      end
      community.data['fuh_facility_id'] = row['fuh_id']

      community.name = row['name']
      community.description = row['facility_description']

      community.care_type = FACILITY_TYPE_VALUES[row['facility_type_id']]

      community.street = row['street']
      community.city = row['city']
      community.state = row['state_abbreviation']
      community.postal = row['zip_code']
      community.country = 'USA'

      for fuh_name, mapping_options in ATTRIBUTE_MAPPINGS
        if row[fuh_name]
          value = row[fuh_name]
          value = mapping_options[:transform].call(value) if mapping_options[:transform]
          if value
            community.data[mapping_options[:as] || fuh_name] = value
          end
        end
      end

      kws = pg.exec("SELECT * FROM keywords kw INNER JOIN facility_keywords fk ON kw.keyword_id = fk.keyword_id WHERE fk.facility_id = '#{row['fuh_id']}'")
      kws.each do |kw|
        fuh_kw = kw['keyword_name'].downcase
        kw_options = KEYWORD_MAPPINGS[fuh_kw]
        if kw_options
          value = true
          value = kw_options[:transform].call(value) if kw_options[:transform]
          if value
            community.data[kw_options[:as] || fuh_kw] = value
          end
        end
      end

      community.save

      unless community.community_images.any?
        images = pg.exec("SELECT * FROM images i INNER JOIN facility_images fi ON i.image_id = fi.image_id WHERE fi.facility_id = '#{row['fuh_id']}'")
        images.each do |image|
          begin
            ci = community.community_images.create(tags: 'fuh')
            ci.image.attach(io: open(image['image_url']), filename: 'image.jpg')
            ci.save
          rescue StandardError
            STDERR.puts "Error fetchcing #{image['image_id']} #{image['image_url']}"
            ci.destroy
          end
        end
      end
    end
  end

  FACILITY_TYPE_VALUES = {
    '1' => 'A',
    '2' => 'M'
  }

  FACILITY_QUALITY_VALUES = {
    '1' => nil,
    '2' => 'resort',
    '3' => 'luxury',
    '4' => 'quality',
    '5' => 'standard',
    '6' => 'serious mentally ill',
  }

  ATTRIBUTE_MAPPINGS = {
    'telephone' => {as: 'phone'},
    'email' => {},
    'fax' => {},
    'facility_url' => {as: 'web'},
    'licensed_beds' => {transform: ->(x) { x.to_i }},
    'entrance_fee' => {transform: ->(x) { x.to_i }},
    'years_private_pay_required' => {as: 'months_pay_required', transform: ->(x) { x.to_i / 12}},
    'base_starting_price' => {as: 'rent_starting_price', transform: ->(x) { x.to_i }},
    'care_starting_price' => {transform: ->(x) { x.to_i }},
    'base_cost_includes_care' => {as: 'rent_includes_care'},
    'facility_quality_id' => {as: 'service_category', transform: ->(x) { FACILITY_QUALITY_VALUES[x] }}
  }

  KEYWORD_MAPPINGS = {
    'jewish' => {as: 'religious_affiliation', transform: ->(x) { 'J'} },
    'budhist' => {as: 'religious_affiliation', transform: ->(x) { 'B'} },
    'christian' => {as: 'religious_affiliation', transform: ->(x) { 'X'} },
    'catholic' => {as: 'religious_affiliation', transform: ->(x) { 'C'} },
    'lutheran' => {as: 'religious_affiliation', transform: ->(x) { 'L'} },
    'smoking' => {},
    'non-smoking' => {as: 'non_smoking'},
    'room_pets' => {as: 'pet_friendly'},
    'gay' => {as: 'lgbt_friendly'},
    'rural setting within untouched nature' => {as: 'setting', transform: ->(x) { 'R'} },
    'lifestyle_city' => {as: 'access_to_city'},
    'lifestyle_outdoors' => {as: 'access_to_outdoors'},

    'full time in house doctor' => {as: 'care_ft_doctor'},
    'on site doctor visits' => {as: 'care_onsite_doctor_visits'},
    'full time in house nurse' => {as: 'care_ft_nurse'},
    'on site nurse visits' => {as: 'care_onsite_nurse_visits'},
    'full time in house nurse (24/7)' => {as: 'care_247_nurse'},
    'on-site healthcare' => {as: 'care_onsite_healthcare'},
    'in-house healthcare' => {as: 'care_onsite_healthcare'},

    'bathing' => {as: 'assistance_bathing'},

    'accepts incontinent residents' => {as: 'care_incontinence'},
    'incontinence management' => {as: 'care_incontinence'},
    'occupational therapy' => {as: 'care_occupational'},
    'physical therapy' => {as: 'care_physical'},
    'rehabilitation' => {as: 'care_rehabilitation'},
    'speech therapy' => {as: 'care_speech'},

    'room_shared' => {as: 'room_shared'},
    'room_private' => {as: 'room_private'},
    'room_studio' => {as: 'room_studio'},
    'room_one_bed' => {as: 'room_one_bed'},
    'room_two_bed' => {as: 'room_two_plus'},
    'room_bathtub' => {as: 'room_feat_bathtub'},
    'customized renovations at move-in' => {as: 'room_feat_custom'},
    'room_kitchen' => {as: 'room_feat_kitchen'},
    'full kitchen' => {as: 'room_feat_kitchen'},
    'kitchenette' => {as: 'room_feat_kitchenette'},
    'room_climate_control' => {as: 'room_feat_climate'},
    'room_smoking' => {as: 'room_feat_smoking'},
    'non smoking rooms' => {as: 'room_feat_nonsmoking'},
    'room_washer' => {as: 'room_feat_washer'},
  }

  # Useful query to look for keywords in FUH database:
  # SELECT k.keyword_id, k.keyword_name, count(fk.facility_id) FROM keywords k inner join facility_keywords fk on fk.keyword_id = k.keyword_id where k.keyword_name like '%share%' group by k.keyword_id LIMIT 100;
end
