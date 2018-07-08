class DataDictionary
  attr_reader :spec

  def initialize(spec)
    @spec = spec
  end

  def validate
    (sections and sections.size > 0) or raise "The specification cannot be empty"

    sections.each {|section|
      (section.has_key?(:section) and section.has_key?(:attrs) and section[:attrs].size > 0) \
      or raise "Sections need a name and attributes"
    }

    all_attrs = attributes

    all_attrs.each {|attr| attr.keys.size == 1 \
    or raise "Attributes should be hashes with a single key, the attribute name (#{attr.inspect})"}

    all_attrs.each {|attr|
      attr.values.first.has_key?(:label) and attr.values.first.has_key?(:data) \
      or raise "Attributes should have labels and data types (#{attr.inspect})"
    }

    attr_counts = all_attrs.collect {|attr| attr.keys.first}.inject(Hash.new(0)) {|counts, key| counts[key] += 1; counts }
    attr_counts.select {|key, count| count > 1}.size == 0 \
    or raise "Duplicate attribute names (#{attr_counts.select {|key, count| count > 1}.collect {|key, count| key}.join(', ')})"

    bad_selects = all_attrs.select {|attr| attr.values.first[:data] == 'select' && attr.values.first[:values].blank?}
    bad_selects.size == 0 \
    or raise "Attributes of type 'select' should have a list of values (#{bad_selects.inspect})"

    return true
  end

  def to_h
    spec
  end

  def sections
    spec
  end

  def attributes
    @attributes ||= spec.collect {|section| section[:attrs]}.flatten
  end

  # DATA TYPES:
  #   flag (boolean, but shown as a tag or flag, shown as things the community *is*)
  #   amenity (boolean, but shown as a list of things the community *has*)
  #   string
  #   text
  #   rating: 0, 1-5
  #   select (values)
  #   phone
  #   email
  #   url
  #   list_of_ids
  #   number  (any integer)
  #   count   (positive integer)
  #   currency (two decimals)
  #   ratio   (1:3)
  #   address (street, city, state, zip, lat, lon)

  Community = self.new([
    { section: "Community",
      attrs: [
        { name:   { label: "Community name", data: 'string', direct_model_attribute: true }},
        { care_type:  { label: "Community type", data: 'select', direct_model_attribute: true,
                        values: [
                          {'A' => "Assisted living"},
                          {'I' => "Independent Living"},
                          {'S' => "Skilled nursing"},
                          {'M' => "Memory care"},
                        ]}},
        { ccrc:   { label: "Continuing care community", data: 'flag' }},
        { parent_company:       { label: "Parent company", data: 'string' }},
        { related_communities:  { label: "Related communities", data: 'list_of_ids'}},

        { phone: { label: "Phone", data: 'phone' }},
        { email: { label: "Email", data: 'email' }},
        { fax:   { label: "Fax", data: 'fax' }},
        { web:   { label: "Web site", data: 'url' }},

        { address: { label: "Address", data: 'string', direct_model_attribute: true }},
        { address_more: { label: "", data: 'string', direct_model_attribute: true }},
        { city: { label: "City", data: 'string', direct_model_attribute: true }},
        { state: { label: "State", data: 'string', direct_model_attribute: true }},
        { postal: { label: "ZIP", data: 'string', direct_model_attribute: true }},
        { country: { label: "Country", data: 'string', direct_model_attribute: true }},
      ],
    },

    { section: "Attributes",
      attrs: [
        { star_rating:            { label: "Rating", data: 'rating' }},
        { description:            { label: "Description", data: 'text', direct_model_attribute: true }},
        { religious_affiliation:  { label: "Religious affiliation", data: 'select',
                                    values: [
                                      {'B' => "Budhist"},
                                      {'C' => "Catholic"},
                                      {'X' => "Christian"},
                                      {'J' => "Jewish"},
                                      {'L' => "Lutheran"},
                                      {'O' => "Other"},
                                    ]}},
        { smoking:                { label: "Smoking", data: 'flag' }},
        { pet_friendly:           { label: "Pet-friendly", data: 'flag' }},
        { lgbt_friendly:          { label: "LGBTQ-friendly", data: 'flag' }},
        { setting:                { label: "Setting", data: 'select',
                                    values: [
                                      {'U' => "Urban"},
                                      {'S' => "Suburban"},
                                      {'R' => "Rural"},
                                    ]}},
        { access_to_city:         { label: "Access to the city", data: 'flag' }},
        { access_to_outdoors:     { label: "Access to the outdoors", data: 'flag' }},
      ]
    },

    { section: "Pricing",
      attrs: [
        { price_rating:           { label: "Price rating", data: 'rating' }},
        { entrance_fee:           { label: "Entrance fee", data: 'price' }},
        { care_starting_price:    { label: "Care cost starting price", data: 'price' }},
        { rent_starting_price:    { label: "Apartment base rent starting price", data: 'price' }},
        { months_pay_required:    { label: "Months of private pay required", data: 'number' }},
        { rent_includes_care:     { label: "Base rent includes care price", data: 'flag' }},
      ]
    },

    { section: "Staff & Care",
      attrs: [
        { bed_count:              { label: "Beds", data: 'count'}},
        { staff_full_time:        { label: "Full-time staff", data: 'count' }},
        { staff_doctors:          { label: "Doctors", data: 'count' }},
        { staff_nurses:           { label: "Licensed nurses", data: 'count' }},
        { staff_socworkers:       { label: "Licensed social workers", data: 'count' }},
        { staff_other:            { label: "Other staff", data: 'count' }},
        { staff_ratio:            { label: "Staff to resident ratio", data: 'number'}},
        { care_ft_doctor:             { label: "Full-Time In House Doctor", data: 'flag' }},
        { care_ft_nurse:              { label: "Full-Time In House Nurse", data: 'flag' }},
        { care_247_nurse:             { label: "Full-Time In House Nurse (24/7)", data: 'flag' }},
        { care_oncall_healthcare:     { label: "On-Call Healthcare", data: 'flag' }},
        { care_onsite_doctor_visits:  { label: "Onsite Doctor Visits", data: 'flag' }},
        { care_onsite_healthcare:     { label: "Onsite Healthcare", data: 'flag' }},
        { care_onsite_nurse_visits:   { label: "Onsite Nurse Visits", data: 'flag' }},

        { assistance_bathing:     { label: "Bathing",   data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_dressing:    { label: "Dressing",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_errands:     { label: "Errands",   data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_grooming:    { label: "Grooming",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_medication:  { label: "Medication Management", data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_mobility:    { label: "Mobility",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_toileting:   { label: "Toileting", data: 'amenity', group_as: 'Personal Assistance' }},

        { care_dementia:          { label: "Alzheimer's/Dementia Care", data: 'amenity', group_as: 'Special Care' }},
        { care_diabetes:          { label: "Diabetes Care", data: 'amenity', group_as: 'Special Care' }},
        { care_incontinence:      { label: "Incontinence Care", data: 'amenity', group_as: 'Special Care' }},
        { care_urinary:           { label: "Incontinence Care (Urinary only)", data: 'amenity', group_as: 'Special Care' }},
        { care_mild_cognitive:    { label: "Mild Cognitive Impairment Care", data: 'amenity', group_as: 'Special Care' }},
        { care_occupational:      { label: "Occupational Therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_parkinsons:        { label: "Parkinsons Care", data: 'amenity', group_as: 'Special Care' }},
        { care_physical:          { label: "Physical Therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_rehabilitation:    { label: "Rehabilitation Program", data: 'amenity', group_as: 'Special Care' }},
        { care_speech:            { label: "Speech Therapy", data: 'amenity', group_as: 'Special Care' }},
      ],
    },

    { section: "Rooms",
      attrs: [
        { room_shared:            { label: "Shared Room", data: 'amenity', group_as: "Room types" }},
        { room_private:           { label: "Private Room", data: 'amenity', group_as: "Room types" }},
        { room_studio:            { label: "Studio", data: 'amenity', group_as: "Room types" }},
        { room_one_bed:           { label: "1 bedroom", data: 'amenity', group_as: "Room types" }},
        { room_two_plus:          { label: "2 Bedrooms +", data: 'amenity', group_as: "Room types" }},
        { room_cottage:           { label: "Cottage/Bungalow", data: 'amenity', group_as: "Room types" }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group_as: "Room features" }},
        { room_feat_custom:       { label: "Custom Renovations Available", data: 'amenity', group_as: "Room features" }},
        { room_feat_kitchen:      { label: "Full Kitchen", data: 'amenity', group_as: "Room features" }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group_as: "Room features" }},
        { room_feat_climate:      { label: "Individual Climate Control", data: 'amenity', group_as: "Room features" }},
        { room_feat_smoking:      { label: "Smoking Room", data: 'amenity', group_as: "Room features" }},
        { room_feat_washer:       { label: "Washer/Dryer", data: 'amenity', group_as: "Room features" }},
      ],
    },

    { section: "Activities",
      attrs: [
        { activity_acting:      { label: "Acting/Drama Club", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_arts:        { label: "Arts & Crafts", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_ceramics:    { label: "Ceramics/Clay", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_comedy:      { label: "Comedy Performance", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_cooking:     { label: "Cooking", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_drawing:     { label: "Drawing & Coloring", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_floral:      { label: "Flower Arranging", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_gardening:   { label: "Gardening", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_knitting:    { label: "Knitting/Crocheting", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_painting:    { label: "Painting", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_poetry:      { label: "Poetry Slams", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_singing:     { label: "Singing/Glee Club", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_woodworking: { label: "Woodworking", data: 'amenity', group_as: "Creativity & performance" }},

        { activity_concerts:          { label: "Concerts & Festivals", data: 'amenity', group_as: "Social & cultural" }},
        { activity_farmers_market:    { label: "Farmer's Market", data: 'amenity', group_as: "Social & cultural" }},
        { activity_film_screenings:   { label: "Film Screenings", data: 'amenity', group_as: "Social & cultural" }},
        { activity_happy_hour:        { label: "Happy Hour", data: 'amenity', group_as: "Social & cultural" }},
        { activity_historical:        { label: "Historical Attractions", data: 'amenity', group_as: "Social & cultural" }},
        { activity_intergenerational: { label: "Intergenerational Activities", data: 'amenity', group_as: "Social & cultural" }},
        { activity_live_music:        { label: "Live Music", data: 'amenity', group_as: "Social & cultural" }},
        { activity_mens_club:         { label: "Men's Club", data: 'amenity', group_as: "Social & cultural" }},
        { activity_museums:           { label: "Museums & Art Galleries", data: 'amenity', group_as: "Social & cultural" }},
        { activity_pet_visits:        { label: "Pet Visits", data: 'amenity', group_as: "Social & cultural" }},
        { activity_shopping:          { label: "Shopping Trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_sporting_events:   { label: "Sporting Events", data: 'amenity', group_as: "Social & cultural" }},
        { activity_tea_time:          { label: "Tea/Coffee Time", data: 'amenity', group_as: "Social & cultural" }},
        { activity_theater_trips:     { label: "Theater Trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_wine_tasting:      { label: "Wine Tasting", data: 'amenity', group_as: "Social & cultural" }},
      ],
    }
  ])
end
