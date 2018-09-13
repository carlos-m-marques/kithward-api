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

    repeated_names = sections.collect {|s| s[:section]}.group_by(&:itself).select {|k, v| v.size > 1}
    repeated_names.length == 0 or raise "Sections need unique names (#{repeated_names.collect {|k, v| k}.join(", ")})"

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
    { section: "Community Details",
      attrs: [
        { name:   { label: "Community name", data: 'string', direct_model_attribute: true }},
        { care_type:  { label: "Community type", data: 'select', direct_model_attribute: true,
                        values: [
                          {'A' => "Assisted Living"},
                          {'I' => "Independent Living"},
                          {'S' => "Skilled Nursing"},
                          {'M' => "Memory Care"},
                        ]}},

        { ccrc:   { label: "Continuing Care Retirement Community", data: 'flag' }},
        { aip:    { label: "Allows 'Aging In Place'", data: 'flag', admin_break_after: 'yes'  }},

        { related_communities:  { label: "Related Communities", data: 'list_of_ids', admin_only: true }},

        { phone: { label: "Phone", data: 'phone' }},
        { email: { label: "Email", data: 'email' }},
        { fax:   { label: "Fax", data: 'fax' }},
        { web:   { label: "Web site", data: 'url' }},

        { street: { label: "Address", data: 'string', direct_model_attribute: true }},
        { street_more: { label: "", data: 'string', direct_model_attribute: true }},
        { city: { label: "City", data: 'string', direct_model_attribute: true }},
        { state: { label: "State", data: 'string', direct_model_attribute: true }},
        { postal: { label: "ZIP", data: 'string', direct_model_attribute: true }},
        { country: { label: "Country", data: 'string', direct_model_attribute: true }},

        { description:            { label: "Description", data: 'text', direct_model_attribute: true }},
        { admin_notes: { label: "Admin Notes", data: 'text', admin_only: true }},

        { star_rating:            { label: "Kithward Rating", data: 'rating', admin_break_after: 'yes' }},

        { community_size:         { label: "Community Size", data: 'select',
                                     values: [
                                       {'S' => 'Small'},
                                       {'M' => 'Medium'},
                                       {'L' => 'Large'},
                                    ]}},
        { bed_count:              { label: "Beds", data: 'count', admin_break_after: 'yes' }},
        
        { staff_total:            { label: "Total Staff", data: 'count' }},
        { staff_full_time:        { label: "Full-Time Staff", data: 'count' }},
        { staff_ratio:            { label: "Staff to Resident Ratio", data: 'number', admin_break_after: 'yes' }},

        { setting:                { label: "Setting", data: 'select',
                                    values: [
                                      {'U' => "Urban setting"},
                                      {'S' => "Suburban setting"},
                                      {'R' => "Rural setting"},
                                    ]}},
        { access_to_city:         { label: "Access to the city", data: 'flag' }},
        { access_to_outdoors:     { label: "Access to the outdoors", data: 'flag', admin_break_after: 'yes' }},
        
        { religious_affiliation:  { label: "Religious affiliation", data: 'select',
                                    values: [
                                      {'-' => 'None'},
                                      {'B' => "Buddhist-affiliated"},
                                      {'C' => "Catholic-affiliated"},
                                      {'X' => "Christian-affiliated"},
                                      {'E' => "Episcopal-affiliated"},
                                      {'J' => "Jewish-affiliated"},
                                      {'L' => "Lutheran-affiliated"},
                                      {'Q' => "Quaker-affiliated"},
                                      {'O' => "Other"},
                                    ]}},
        { lgbt_friendly:          { label: "LGBTQ focus", data: 'flag', admin_break_after: 'yes' }},

        { smoking:                { label: "Smoking allowed", data: 'flag' }},
        { non_smoking:            { label: "Smoking prohibited", data: 'flag', admin_break_after: 'yes' }},
        
        { pet_friendly:           { label: "Pet-friendly", data: 'flag' }},
        { pet_policy:             { label: "Pet policy", data: 'string' }},
      ]
    },

    { section: "Kithward Color",
      attrs: [
        { kithward_color:         { label: "Kithward Color", data: 'text' }},
        { kithward_color_y:       { label: "Display Kithward Color", data: 'flag' }},
      ],
    },

    { section: "Accomodations",
      desc: "Here are the various types of units available to choose from, subject to availability. " \
            "There may be more options than what are shown. Contact us to find out more.",
      attrs: [
        { room_shared:            { label: "Shared room", data: 'amenity', group_as: "Unit Sizes" }},
        { room_private:           { label: "Private room", data: 'amenity', group_as: "Unit Sizes" }},
        { room_studio:            { label: "Studio", data: 'amenity', group_as: "Unit Sizes" }},
        { room_one_bed:           { label: "1 bedroom", data: 'amenity', group_as: "Unit Sizes" }},
        { room_two_plus:          { label: "2 bedrooms +", data: 'amenity', group_as: "Unit Sizes" }},
        { room_dettached:         { label: "Detached home", data: 'amenity', group_as: "Unit Sizes" }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group_as: "Available Features" }},
        { room_feat_custom:       { label: "Custom renovations available", data: 'amenity', group_as: "Available Features" }},
        { room_feat_den:          { label: "Den/extra room", data: 'amenity', group_as: "Available Features" }},
        { room_feat_dishwasher:   { label: "Dishwasher", data: 'amenity', group_as: "Available Features" }},
        { room_feat_kitchen:      { label: "Full kitchen", data: 'amenity', group_as: "Available Features" }},
        { room_feat_climate:      { label: "Individual climate control", data: 'amenity', group_as: "Available Features" }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group_as: "Available Features" }},
        { room_feat_pvt_outdoor:  { label: "Private outdoor space", data: 'amenity', group_as: "Available Features" }},
        { room_feat_walkin:       { label: "Walk-in closet", data: 'amenity', group_as: "Available Features" }},
        { room_feat_washer:       { label: "Washer/dryer", data: 'amenity', group_as: "Available Features" }},

        { room_floorplans:        { label: "Sample Floor Plans", data: 'ignore', special: 'thumbnails', tagged_as: 'floorplan'}},
      ],
    },

    { section: "Pricing Summary",
      desc: "Pricing can vary greatly depending on the accomodations you choose and the " \
            "level of assistance you require, if any. Contact us to find out more.",
      attrs: [
        { price_rating:           { label: "Price Rating", data: 'rating', admin_break_after: 'yes' }},

        { rent_starting_price:    { label: "Base Rent Minimum", data: 'price' }},
        { rent_maximum_price:     { label: "Base Rent Maximum", data: 'price' }},
        { rent_includes_care:     { label: "Base Rent Includes Care Cost", data: 'flag', admin_break_after: 'yes' }},

        { care_starting_price:    { label: "Care Cost Minimum", data: 'price' }},
        { care_maximum_price:     { label: "Care Cost Maximum", data: 'price', admin_break_after: 'yes' }},

        { entrance_fee_min:       { label: "Minimum Entrance Fee", data: 'price' }},
        { entrance_fee_max:       { label: "Maximum Entrance Fee", data: 'price', admin_break_after: 'yes' }},

        { public_pricing_notes:   { label: "Additional Pricing Information", data: 'text' }},
        { admin_pricing_notes:    { label: "Admin Pricing Notes", data: 'text', admin_only: true }},
      ]
    },

    { section: "Care & Support",
      desc: "Here you will find the types of healthcare, assistance and support offered at this community, some of which " \
            "may come with an additional cost.",
      attrs: [
        { staff_doctors:              { label: "Doctors", data: 'count' }},
        { staff_doctors_ft:           { label: "Full-Time Doctors", data: 'count' }},
        { staff_nurses:               { label: "Licensed Nurses", data: 'count' }},
        { staff_nurses_ft:            { label: "Full-time Licensed Nurses", data: 'count' }},
        { staff_socworkers:           { label: "Licensed Social Workers", data: 'count' }},
        { staff_socworkers_ft:        { label: "Full-Time Licensed Social Workers", data: 'count' }},

        { care_ft_doctor:             { label: "Full-time doctor", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_ft_nurse:              { label: "Full-time nurse", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_247_nurse:             { label: "Full-time nurse (24/7)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_RN:                    { label: "Registered nurse (RN)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_LPN:                   { label: "Licensed practical nurse (LPN)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_social_worker:         { label: "Social worker(s)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_onsite_doctor_visits:  { label: "Doctor visits", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_onsite_nurse_visits:   { label: "Nurse visits", data: 'flag', group_as: 'Healthcare Staff' }},
        
        { care_onsite_audiologist:    { label: "Audiologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_cardiologist:   { label: "Cardiologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_dentist:        { label: "Dentist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_dermatologist:  { label: "Dermatologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_dietician:      { label: "Dietician", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_endocronologist: { label: "Endocronologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_internist:      { label: "Internist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_neurologist:    { label: "Neurologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_opthamologist:  { label: "Opthamologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_optometrist:    { label: "Optometrist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_podiatrist:     { label: "Podiatrist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_pulmonologist:  { label: "Pulmonologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_psychologist:   { label: "Psychologist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_psychiatrist:   { label: "Psychiatrist", data: 'flag', group_as: 'Visiting Specialists' }},
        { care_onsite_urologist:      { label: "Urologist", data: 'flag', group_as: 'Visiting Specialists' }},


        { assistance_bathing:     { label: "Bathing assistance",   data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_dressing:    { label: "Dressing assistance",  data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_errands:     { label: "Escorts for errands",   data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_grooming:    { label: "Grooming assistance",  data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_medication:  { label: "Medication management", data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_mobility:    { label: "Mobility assistance",  data: 'amenity', group_as: 'Day-to-Day Assistance' }},
        { assistance_toileting:   { label: "Toileting assistance", data: 'amenity', group_as: 'Day-to-Day Assistance' }},

        { care_dementia:          { label: "Alzheimer's/dementia care", data: 'amenity', group_as: 'Special Care' }},
        { care_diabetes:          { label: "Diabetes care", data: 'amenity', group_as: 'Special Care' }},
        { care_incontinence:      { label: "Incontinence care", data: 'amenity', group_as: 'Special Care' }},
        { care_urinary:           { label: "Incontinence care (Urinary only)", data: 'amenity', group_as: 'Special Care' }},
        { care_mild_cognitive:    { label: "Mild cognitive impairment care", data: 'amenity', group_as: 'Special Care' }},
        { care_music_therapy:     { label: "Music therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_occupational:      { label: "Occupational therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_parkinsons:        { label: "Parkinson's care", data: 'amenity', group_as: 'Special Care' }},
        { care_physical:          { label: "Physical therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_rehabilitation:    { label: "Rehabilitation program", data: 'amenity', group_as: 'Special Care' }},
        { care_speech:            { label: "Speech therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_wellness:          { label: "Wellness program", data: 'amenity', group_as: 'Special Care' }},
      ],
    },

    { section: "Services",
      desc: "Staff and visiting professionals offer a variety of services to make residents lives easier, though some " \
            "may come with an additional cost or be subject to availability.",
      attrs: [
        { services_banking:        { label: "Banking services", data: 'amenity', group_as: "Available Services" }},
        { services_cable:          { label: "Cable included", data: 'amenity', group_as: "Available Services" }},
        { services_concierge:      { label: "Concierge", data: 'amenity', group_as: "Available Services" }},
        { services_domestic_phone: { label: "Domestic phone included", data: 'amenity', group_as: "Available Services" }},        
        { services_drycleaning:    { label: "Dry-cleaning services", data: 'amenity', group_as: "Available Services" }},
        { services_hairdresser:    { label: "Hairdresser/barber", data: 'amenity', group_as: "Available Services" }},
        { services_housekeeping:   { label: "Housekeeping", data: 'amenity', group_as: "Available Services" }},
        { services_laundry:        { label: "Laundry service", data: 'amenity', group_as: "Available Services" }},
        { services_linen:          { label: "Linen service", data: 'amenity', group_as: "Available Services" }},
        { services_manicurist:     { label: "Manicurist", data: 'amenity', group_as: "Available Services" }},
        { services_massage:        { label: "Massage therapist", data: 'amenity', group_as: "Available Services" }},
        { services_newspaper:      { label: "Newspaper delivery", data: 'amenity', group_as: "Available Services" }},
        { services_volunteers:     { label: "Outside volunteers", data: 'amenity', group_as: "Available Services" }},
        { services_pharmacy:       { label: "Pharmacy services", data: 'amenity', group_as: "Available Services" }},
        { services_chaplain:       { label: "Priest/chaplain", data: 'amenity', group_as: "Available Services" }},
        { services_catering:       { label: "Private event catering", data: 'amenity', group_as: "Available Services" }},
        { services_rabbi:          { label: "Rabbi", data: 'amenity', group_as: "Available Services" }},
        { services_wifi:           { label: "WiFi included", data: 'amenity', group_as: "Available Services" }},
        { services_wifi_common:    { label: "WiFi in common areas", data: 'amenity', group_as: "Available Services" }},
        
        { services_shuttle_service:     { label: "Car/shuttle service", data: 'amenity', group_as: "Parking & Transportation" }},
        { services_parking:             { label: "Parking available", data: 'amenity', group_as: "Parking & Transportation" }},
        { services_scheduled_transport: { label: "Scheduled transportation", data: 'amenity', group_as: "Parking & Transportation" }},
        { services_transportation:      { label: "Transportation arrangement", data: 'amenity', group_as: "Parking & Transportation" }},
        { services_valet_parking:       { label: "Valet parking", data: 'amenity', group_as: "Parking & Transportation" }},

        { security_electronic_key:             { label: "Electronic key entry system", data: 'flag', group_as: "Security" }},
        { security_emergency_pendant:          { label: "Emergency alert pendants", data: 'flag', group_as: "Security" }},
        { security_ft_security:                { label: "Full-time security staff", data: 'flag', group_as: "Security" }},
        { security_emergency_call:             { label: "In-room emergency call system", data: 'flag', group_as: "Security" }},
        { security_night_checks:               { label: "Night checks", data: 'flag', group_as: "Security" }},
        { security_safety_checks:              { label: "Regular safety checks", data: 'flag', group_as: "Security" }},
        { security_secure_memory:              { label: "Secure memory unit", data: 'flag', group_as: "Security" }},
        { security_security_system:            { label: "Security system", data: 'flag', group_as: "Security" }},
        { security_staff_background_checks:    { label: "Staff background checks", data: 'flag', group_as: "Security" }},
        { security_video_surveillance:         { label: "Video surveillance", data: 'flag', group_as: "Security" }},
        { security_visitor_checkins:           { label: "Visitor check-in", data: 'flag', group_as: "Security" }},
      ],
    },
    
    { section: "Dining",
      desc: "Here you will find the style of dining offered at the community, as well as the types of diets " \
            "they can accomodate. If you have special restrictions, contact us to find out more.",
      attrs: [
        { food_3_meals:           { label: "3 meals daily", data: 'amenity', group_as: "Dining Style" }},
        { diet_foodie_friendly:   { label: "Chef-prepared meals", data: 'amenity', group_as: "Dining Style" }},
        { food_all_day:           { label: "Dining available all day", data: 'amenity', group_as: "Dining Style" }},
        { food_guest_meals:       { label: "Guest meals", data: 'amenity', group_as: "Dining Style" }},
        { food_meal_vouchers:     { label: "Meal plans/vouchers", data: 'amenity', group_as: "Dining Style" }},        
        { food_restaurant_style:  { label: "Restaurant-style dining", data: 'amenity', group_as: "Dining Style" }},
        { food_room_service:      { label: "Room service", data: 'amenity', group_as: "Dining Style" }},
        { food_24h_snacks:        { label: "Snacks available all day", data: 'amenity', group_as: "Dining Style" }},

        { diet_restricted:        { label: "Restricted diets", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_gluten_free:       { label: "Gluten-free", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_kosher_meals:      { label: "Kosher meals", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_pureed:            { label: "Pureed", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_vegan:             { label: "Vegan", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_vegetarian:        { label: "Vegetarian", data: 'amenity', group_as: "Dietary Accomodations" }},

        { food_menus:             { label: "Sample Menus", data: 'ignore', special: 'thumbnails', tagged_as: 'menu'}},
      ],
    },

    { section: "Activities",
      desc: "Activity calendars speak volumes about the culture of a community. Learn what " \
            " opportunities there are to socialize, stay fit, be creative, stay engaged, grow " \
            "spiritually, and more.",
      attrs: [
        { activity_acting:            { label: "Acting/drama", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_arts:              { label: "Arts & crafts", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_ceramics:          { label: "Ceramics/clay", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_chimes:            { label: "Chimes/bell choir", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_comedy:            { label: "Comedy performance", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_cooking:           { label: "Cooking/baking", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_drawing:           { label: "Drawing & coloring", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_floral:            { label: "Flower arranging", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_gardening:         { label: "Gardening", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_knitting:          { label: "Knitting/crocheting", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_painting:          { label: "Painting", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_poetry:            { label: "Poetry readings", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_singing:           { label: "Singing/choir", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_woodworking:       { label: "Woodworking", data: 'amenity', group_as: "Creative & Artistic" }},

        { activity_aquatics:          { label: "Aquatics/water aerobics", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_balance:           { label: "Balance/stability", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_biking:            { label: "Biking", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_bocce:             { label: "Bocce ball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_bowling:           { label: "Bowling", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_cardio_machines:   { label: "Cardio machines", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_chair_exercise:    { label: "Chair exercise", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_dancing:           { label: "Dancing", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_fitness_classes:   { label: "Fitness classes", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_golf:              { label: "Golf/putting", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_hiking:            { label: "Hiking", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_horseback:         { label: "Horseback riding", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_lawn_games:        { label: "Lawn games", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_personal_training: { label: "Personal training", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pickleball:        { label: "Pickleball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pilates:           { label: "Pilates", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_ping_pong:         { label: "Ping pong", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquet_sports:    { label: "Racquet sports", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquetball:       { label: "Racquetball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_shuffleboard:      { label: "Shuffleboard", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_squash:            { label: "Squash", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_strength:          { label: "Strength training", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_stretching:        { label: "Stretching", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_swimming:          { label: "Swimming", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tai_chi:           { label: "Tai chi", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tennis:            { label: "Tennis", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_walking_club:      { label: "Walking club", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_yoga:              { label: "Yoga", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_zumba:             { label: "Zumba", data: 'amenity', group_as: "Fitness & Exercise" }},

        { activity_billiards:         { label: "Billiards/pool", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_bingo:             { label: "Bingo", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_blackjack:         { label: "Blackjack", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_board_games:       { label: "Board games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_bridge:            { label: "Bridge", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_card_games:        { label: "Card games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_dominos:           { label: "Dominos", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_mahjong:           { label: "Mahjong", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_party_games:       { label: "Party games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_pokeno:            { label: "Pokeno", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_poker:             { label: "Poker", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_puzzles:           { label: "Puzzles", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_rummikub:          { label: "Rummikub", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_trivia:            { label: "Trivia/brain games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_video_games:       { label: "Video games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_word_games:        { label: "Word games", data: 'amenity', group_as: "Games & Trivia" }},
        
        { activity_art_classes:             { label: "Art classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_book_club:               { label: "Book club/reading group", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_technology_classes:      { label: "Computer classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_current_events:          { label: "Current events", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_discussion_groups:       { label: "Discussion groups", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_language_classes:        { label: "Language classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_lectures:                { label: "Lectures/classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_lending_program:         { label: "Local library lending program", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_music_appreciation:      { label: "Music/art appreciation", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_music_classes:           { label: "Music classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_writing_classes:         { label: "Writing classes", data: 'amenity', group_as: "Lifelong Learning" }},

        { activity_bible_study:             { label: "Bible fellowship/study", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_catholic_mass:           { label: "Catholic mass/communion", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_christian_services:      { label: "Christian services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_clergy:                  { label: "Clergy visits", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_episcopal:               { label: "Episcopal services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_hindu_prayer:            { label: "Hindu prayer", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_meditation:              { label: "Meditation", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_nondenominational:       { label: "Non-denominational faith group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_nondenominational_svcs:  { label: "Non-denominational services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_quaker_services:         { label: "Quaker services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_rabbi_study:             { label: "Rabbi study group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_rosary_group:            { label: "Rosary group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_shabbat_services:        { label: "Shabbat services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_church_bus:              { label: "Transportation to church", data: 'amenity', group_as: "Religious & Spiritual" }},
        
        { activity_charity:                 { label: "Charity/outreach", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_civic:                   { label: "Civic engagement", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_happy_hour:              { label: "Happy/social Hour", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_intergenerational:       { label: "Intergenerational activities", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_karaoke:                 { label: "Karaoke", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_live_music:              { label: "Live music/entertainment", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_mens_club:               { label: "Men's club", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_movies:                  { label: "Movies", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_multicultural:           { label: "Multicultural activities", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_pet_visits:              { label: "Pet visits", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_vendors:                 { label: "Retail vendor visits", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_sharing:                 { label: "Sharing/storytelling", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_travel:                  { label: "Travel club", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_tea_time:                { label: "Tea/coffee time", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_watching_sports:         { label: "Watching sports", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_wine_tasting:            { label: "Wine tasting", data: 'amenity', group_as: "Social & Entertainment" }},

        { activity_casino_trips:            { label: "Casinos", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_city_trips:              { label: "City trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_farmers_market:          { label: "Farmer's market", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_historical:              { label: "Historical/tourist attractions", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_mall:                    { label: "Mall trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_museums:                 { label: "Museums/art galleries", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_concerts:                { label: "Music performances/concerts", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_nature_trips:            { label: "Nature trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_dining_out:              { label: "Restaurants", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_shopping:                { label: "Shopping/errands", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_sporting_events:         { label: "Sporting events", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_theater:                 { label: "Theater/performing arts", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_wineries:                { label: "Wineries", data: 'amenity', group_as: "Trips & Outings" }},

        { activity_calendars:   { label: "Sample Calendars", data: 'ignore', special: 'thumbnails', tagged_as: 'calendar'}},
      ],
    },

    { section: "Amenities",
      desc: "Amenities represent the 'bones' of a community: the rooms, facilities, features and infrastructure " \
            "meant to enhance and enrich the lives of its residents.",
      attrs: [
        { amenity_ATM:                 { label: "ATM", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_crafts_room:         { label: "Arts & crafts room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_bank:                { label: "Bank", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_pub:                 { label: "Bar/pub", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_billiards_table:     { label: "Billiards/pool table", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_cafe:                { label: "Cafe/bistro", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_chapel:              { label: "Chapel/worship space", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_classroom:           { label: "Classroom/lecture hall", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_walkways:            { label: "Climate-controlled walkways", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_clubhouse:           { label: "Clubhouse", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_common_kitchen:      { label: "Common kitchen", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_computer_room:       { label: "Computer room/area", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_fireplace:           { label: "Fireplaces", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_game_room:           { label: "Game/card room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_hair_salon:          { label: "Hair salon/barber", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_laundry:             { label: "Laundry room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_library:             { label: "Library", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_lounge:              { label: "Lounge/community room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_media_room:          { label: "Media/film room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_meditation_room:     { label: "Meditation/prayer room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_theater:             { label: "Movie theater", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_music_room:          { label: "Music room/conservatory", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_nail_salon:          { label: "Nail salon", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_guest_suite:         { label: "Overnight guest suite", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_piano:               { label: "Piano", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_pharmacy:            { label: "Pharmacy", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_private_dining_room: { label: "Private dining room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_private_kitchen:     { label: "Private kitchen", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_restaurant:          { label: "Restaurant", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_spa:                 { label: "Spa", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_stage:               { label: "Stage/theater", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_store:               { label: "Store", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_sun_room:            { label: "Sun room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_tea_room:            { label: "Tea/coffee room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_vending_machines:    { label: "Vending machines", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_wellness_center:     { label: "Wellness center", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_woodworking_shop:    { label: "Woodworking shop", data: 'amenity', group_as: "Indoor Amenities" }},

        { amenity_walking_paths:           { label: "Walking paths", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_hiking_trails:           { label: "Hiking trails", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_biking_trails:           { label: "Biking trails", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_courtyard:               { label: "Courtyard", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_fountain:                { label: "Fountain/water feature", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_garden:                  { label: "Garden", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_gazebo:                  { label: "Gazebo", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_greenhouse:              { label: "Greenhouse", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_landscaped:              { label: "Landscaped grounds", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_lawn:                    { label: "Lawn", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_grill:                   { label: "Outdoor grill", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_outdoor_dining:          { label: "Outdoor dining area", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_pond:                    { label: "Pond/lake", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_porch:                   { label: "Porch/patio", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_wooded_area:             { label: "Wooded area", data: 'amenity', group_as: "Outdoor Amenities" }},

        { amenitiy_fitness_equipment_room: { label: "Fitness equipment room", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_exercise_room:          { label: "Exercise room", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_fitness_center:         { label: "Fitness center", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_full_gym:               { label: "Full-sized gym", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_athletic_club:          { label: "Athletic club", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_sauna:                  { label: "Sauna", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenitiy_steam_room:             { label: "Steam room", data: 'amenity', group_as: "Fitness Facilities" }},

        { amenity_indoor_pool:           { label: "Indoor pool", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_outdoor_pool:          { label: "Outdoor pool", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_multiple_pools:        { label: "Multiple pools", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_hot_tub:               { label: "Whirlpool/hot tub", data: 'amenity', group_as: "Fitness Facilities" }},

        { amenity_golf_18hole:           { label: "18-hole golf course", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_gold_9hole:            { label: "9-hole golf course", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_multiple_golf_courses: { label: "Multiple golf courses", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_golf_nearby:           { label: "Golf courses nearby", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_indoor_driving_range:  { label: "Indoor driving range", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_outdoor_driving_range: { label: "Outdoor driving range", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_indoor_putting:        { label: "Indoor putting area", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_outdoor_putting:       { label: "Outdoor putting area", data: 'amenity', group_as: "Fitness Facilities" }},

        { amenity_pickleball_court:      { label: "Pickleball court", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_ping_pong:             { label: "Ping pong table", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_racquetball_court:     { label: "Racquet ball court", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_squash_court:          { label: "Squash court", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_tennis_court:          { label: "Tennis court", data: 'amenity', group_as: "Fitness Facilities" }},

        { amenity_bocce_court:           { label: "Bocce ball court", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_bowling_alley:         { label: "Bowling alley", data: 'amenity', group_as: "Fitness Facilities" }},
        { amenity_shuffleboard_court:    { label: "Shuffleboard court", data: 'amenity', group_as: "Fitness Facilities" }},
      ],
    },

    { section: "Community Governance",
      attrs: [
        { parent_company:                  { label: "Operator", data: 'string', admin_only: true }},

        { ownership_nonprofit_religious:   { label: "Religious Non-Profit", data: 'flag', group_as: 'Ownership' }},
        { ownership_nonprofit_secular:     { label: "Secular Non-Profit", data: 'flag', group_as: 'Ownership' }},
        { ownership_private:               { label: "Privately Held", data: 'flag', group_as: 'Ownership' }},
        { ownership_private_equity:        { label: "Private Equity Backed", data: 'flag', group_as: 'Ownership' }},
        { ownership_reit:                  { label: "REIT", data: 'flag', group_as: 'Ownership' }},
        { ownership_public_company:        { label: "Public Company", data: 'flag', group_as: 'Ownership' }},

        { resident_council_finances:       { label: "Influences budget/financial decisions", data: 'flag', group_as: 'Resident Council' }},
        { resident_council_programming:    { label: "Chooses programming", data: 'flag', group_as: 'Resident Council' }},
        { resident_council_advice:         { label: "Provides advice to management", data: 'flag', group_as: 'Resident Council' }},

        { admin_care_decision_notes:       { label: "Admin Care Decision Notes", data: 'string', admin_only: true }},

        { admin_governance_notes:          { label: "Admin Governance Notes", data: 'text', admin_only: true }},
      ],
    },

    { section: "Community Values",
      attrs: [
        { community_values:                { label: "Community Values", data: 'text' }},
      ],
    },

    { section: "Awards & Certifications",
      attrs: [
        { community_awards:                { label: "Awards & Certifications", data: 'text' }},

      ],
    },

    { section: "Community Makeup",
      attrs: [
        { resident_profile_professions:    { label: "Former Professions", data: 'string' }},
        { resident_profile_interests:      { label: "Interests & Hobbies", data: 'string' }},
        { resident_profile_cultures:       { label: "Cultural Backgrounds", data: 'string' }},
        { resident_profile_religions:      { label: "Religions Represented", data: 'string' }},
        { resident_profile_politics:       { label: "Political Leanings", data: 'select',
                                             values: [
                                               {'-' => 'None specified'},
                                               {'C' => "Conservative"},
                                               {'M' => "Moderate"},
                                               {'P' => "Progressive"},
                                    ]}},
        { resident_profile_education:      { label: "Education Level", data: 'select',
                                             values: [
                                               {'-' => 'None specified'},
                                               {'C' => "Most have graduate degrees"},
                                               {'M' => "Most have college degrees"},
                                               {'P' => "Most are high school graduates"},
                                     ]}},

      ],
    },

    { section: "Contract Options",
      attrs: [
        { contract_type_extensive:     { label: "Extensive (Life Care)", data: 'flag', group_as: "Contract Types" }},
        { contract_type_modified:      { label: "Modified", data: 'flag', group_as: "Contract Types" }},
        { contract_type_fee:           { label: "Fee for Service", data: 'flag', group_as: "Contract Types" }},
        { contract_type_rental:        { label: "Rental", data: 'flag', group_as: "Contract Types" }},
        { contract_type_equity:        { label: "Equity", data: 'flag', group_as: "Contract Types" }},

        { entrance_fee_required:       { label: "Entrance Fee Required", data: 'flag', group_as: "Entrance Fee & Refund" }},
        { refund_option:               { label: "Entrance Fee Refund Option", data: 'flag', group_as: "Entrance Fee & Refund" }},
        { refund_option_min:           { label: "Minimum Refund Offered", data: 'count', group_as: "Entrance Fee & Refund" }},
        { refund_option_max:           { label: "Maximum Refund Offered", data: 'count', group_as: "Entrance Fee & Refund" }},
        { refund_conditions:           { label: "Conditions for Refund", data: 'string', group_as: "Entrance Fee & Refund" }},
        { entrance_fee_amort:          { label: "Amortization Details", data: 'text', group_as: "Entrance Fee & Refund" }},

        ],
    },

    { section: "Entrance Requirements",
      attrs: [
        { requires_age_qual:          { label: "Requires age qualification", data: 'flag' }},
        { age_qual_requirements:      { label: "Age qualification requirements", data: 'string' }},
        { requires_medical_qual:      { label: "Requires medical qualification", data: 'flag' }},
        { medical_qual_requirements:  { label: "Medical qualification requirements", data: 'string' }},
        { requires_insurance:         { label: "Requires insurance", data: 'flag' }},
        { accepts_medicare:           { label: "Accepts Medicare", data: 'flag' }},
        { accepts_medicare_supl:      { label: "Accepts Medicare supplement", data: 'flag' }},
        { accepts_private_ins:        { label: "Accepts private plan insurance", data: 'flag' }},
        { accepts_long_term_ins:      { label: "Accepts long-term care insurance", data: 'flag' }},
        { insurance_requirements:     { label: "Insurance requirements", data: 'string' }},
        { requires_income_qual:       { label: "Requires financial qualification", data: 'flag' }},
        { income_qual_requirements:   { label: "Financial qualification requirements", data: 'string' }},

      ]
    },

  ])
end
