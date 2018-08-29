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

        { parent_company:       { label: "Parent company", data: 'string', admin_only: true }},
        { related_communities:  { label: "Related communities", data: 'list_of_ids', admin_only: true }},

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
        { admin_notes: { label: "Admin Notes", data: 'text', admin_only: true }},
      ],
    },

    { section: "Attributes",
      attrs: [
        { star_rating:            { label: "Rating", data: 'rating' }},
        { description:            { label: "Description", data: 'text', direct_model_attribute: true }},
        { religious_affiliation:  { label: "Religious affiliation", data: 'select',
                                    values: [
                                      {'-' => 'None'},
                                      {'B' => "Budhist"},
                                      {'C' => "Catholic"},
                                      {'X' => "Christian"},
                                      {'J' => "Jewish"},
                                      {'L' => "Lutheran"},
                                      {'O' => "Other"},
                                    ]}},
        { smoking:                { label: "Smoking", data: 'flag' }},
        { non_smoking:            { label: "Non-smoking", data: 'flag' }},
        { pet_friendly:           { label: "Pet-friendly", data: 'flag' }},
        { pet_policy:             { label: "Pet policy", data: 'string' }},
        { lgbt_friendly:          { label: "LGBTQ focus", data: 'flag' }},
      ]
    },

    { section: "Setting",
      attrs: [
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
        { rent_starting_price:    { label: "Base rent starting price", data: 'price' }},
        { rent_maximum_price:     { label: "Base rent maximum price", data: 'price' }},
        { rent_includes_care:     { label: "Base rent includes care price", data: 'flag' }},
        { care_starting_price:    { label: "Care cost starting price", data: 'price' }},
        { care_maximum_price:     { label: "Care cost maximum price", data: 'price' }},

        { entrance_fee_min:       { label: "Minimum entrance fee", data: 'price' }},
        { entrance_fee_max:       { label: "Maximum entrance fee", data: 'price' }},

        { months_pay_required:    { label: "Months of private pay required", data: 'number' }},

        { admin_pricing_notes:    { label: "Admin Pricing Notes", data: 'text', admin_only: true }},
      ]
    },

    { section: "Entrance Requirements",
      attrs: [
        { requires_age_qual:          { label: "Requires age qualification", data: 'flag' }},
        { age_qual_requirements:      { label: "Age qualification requirements", data: 'string' }},
        { requires_medical_qual:      { label: "Requires medical qualification", data: 'flag' }},
        { medical_qual_requirements:  { label: "Medical qualification requirements", data: 'string' }},
        { requires_insurance:         { label: "Requires insurance", data: 'flag' }},
        { insurance_requirements:     { label: "Requires insurance", data: 'string' }},
        { accepts_medicare:           { label: "Accepts Medicare", data: 'flag' }},
        { accepts_medicare_supl:      { label: "Accepts Medicare supplement", data: 'flag' }},
        { accepts_private_ins:        { label: "Accepts private plan insurance", data: 'flag' }},
        { accepts_long_term_ins:      { label: "Accepts long-term care insurance", data: 'flag' }},
        { requires_income_qual:       { label: "Requires income qualification", data: 'flag' }},
        { income_qual_requirements:   { label: "Requires income qualification", data: 'string' }},
        { requires_asset_qual:        { label: "Requires asset qualification", data: 'flag' }},
        { asset_qual_requirements:    { label: "Requires asset qualification", data: 'string' }},
      ]
    },

    { section: "Staff & Care",
      attrs: [
        { community_size:         { label: "Community size", data: 'select',
                                    values: [
                                        {'S' => 'Small'},
                                        {'M' => 'Medium'},
                                        {'L' => 'Large'},
                                      ]}},

        { bed_count:              { label: "Beds", data: 'count'}},

        { staff_total:            { label: "Total staff", data: 'count' }},
        { staff_full_time:        { label: "Full-time staff", data: 'count' }},
        { staff_doctors:          { label: "Doctors", data: 'count' }},
        { staff_doctors_ft:       { label: "Full-time doctors", data: 'count' }},
        { staff_nurses:           { label: "Licensed nurses", data: 'count' }},
        { staff_nurses_ft:        { label: "Full-time licensed nurses", data: 'count' }},
        { staff_socworkers:       { label: "Licensed social workers", data: 'count' }},
        { staff_socworkers_ft:    { label: "Full-time licensed social workers", data: 'count' }},
        { staff_other:            { label: "Other staff", data: 'count' }},

        { staff_ratio:            { label: "Staff to resident ratio", data: 'number'}},

        { care_ft_doctor:             { label: "Full-Time In House Doctor", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_ft_nurse:              { label: "Full-Time In House Nurse", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_247_nurse:             { label: "Full-Time In House Nurse (24/7)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_oncall_healthcare:     { label: "On-Call Healthcare", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_onsite_doctor_visits:  { label: "Onsite Doctor Visits", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_onsite_nurse_visits:   { label: "Onsite Nurse Visits", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_onsite_healthcare:     { label: "Onsite Healthcare", data: 'flag', group_as: 'Healthcare Staff' }},

        { security_emergency_call:    { label: "Emergency call system", data: 'flag' }},
        { security_inroom_monitoring: { label: "In-room monitoring", data: 'flag' }},
        { security_night_checks:      { label: "Night checks", data: 'flag' }},


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
        { room_dettached:         { label: "Dettached home", data: 'amenity', group_as: "Room types" }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group_as: "Room features" }},
        { room_feat_custom:       { label: "Custom Renovations Available", data: 'amenity', group_as: "Room features" }},
        { room_feat_kitchen:      { label: "Full Kitchen", data: 'amenity', group_as: "Room features" }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group_as: "Room features" }},
        { room_feat_dishwasher:   { label: "Dishwasher", data: 'amenity', group_as: "Room features" }},
        { room_feat_climate:      { label: "Individual Climate Control", data: 'amenity', group_as: "Room features" }},
        { room_feat_smoking:      { label: "Smoking in room", data: 'amenity', group_as: "Room features" }},
        { room_feat_nonsmoking:   { label: "Non-Smoking Rooms", data: 'amenity', group_as: "Room features" }},
        { room_feat_washer:       { label: "Washer/Dryer", data: 'amenity', group_as: "Room features" }},
      ],
    },

    { section: "Activities",
      attrs: [
        { activity_acting:            { label: "Acting/Drama Club", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_arts:              { label: "Arts & Crafts", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_ceramics:          { label: "Ceramics/Clay", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_comedy:            { label: "Comedy Performance", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_cooking:           { label: "Cooking", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_drawing:           { label: "Drawing & Coloring", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_floral:            { label: "Flower Arranging", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_gardening:         { label: "Gardening", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_knitting:          { label: "Knitting/Crocheting", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_painting:          { label: "Painting", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_poetry:            { label: "Poetry Slams", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_singing:           { label: "Singing/Glee Club", data: 'amenity', group_as: "Creativity & performance" }},
        { activity_woodworking:       { label: "Woodworking", data: 'amenity', group_as: "Creativity & performance" }},

        { activity_city_trips:        { label: "City trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_concerts:          { label: "Concerts & Festivals", data: 'amenity', group_as: "Social & cultural" }},
        { activity_farmers_market:    { label: "Farmer's Market", data: 'amenity', group_as: "Social & cultural" }},
        { activity_film_screenings:   { label: "Film Screenings", data: 'amenity', group_as: "Social & cultural" }},
        { activity_happy_hour:        { label: "Happy Hour", data: 'amenity', group_as: "Social & cultural" }},
        { activity_historical:        { label: "Historical Attractions", data: 'amenity', group_as: "Social & cultural" }},
        { activity_intergenerational: { label: "Intergenerational Activities", data: 'amenity', group_as: "Social & cultural" }},
        { activity_live_music:        { label: "Live Music", data: 'amenity', group_as: "Social & cultural" }},
        { activity_mens_club:         { label: "Men's Club", data: 'amenity', group_as: "Social & cultural" }},
        { activity_museums:           { label: "Museums & Art Galleries", data: 'amenity', group_as: "Social & cultural" }},
        { activity_nature_trips:      { label: "Nature trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_pet_visits:        { label: "Pet Visits", data: 'amenity', group_as: "Social & cultural" }},
        { activity_shopping:          { label: "Shopping Trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_sporting_events:   { label: "Sporting Events", data: 'amenity', group_as: "Social & cultural" }},
        { activity_tea_time:          { label: "Tea/Coffee Time", data: 'amenity', group_as: "Social & cultural" }},
        { activity_theater_trips:     { label: "Theater Trips", data: 'amenity', group_as: "Social & cultural" }},
        { activity_wine_tasting:      { label: "Wine Tasting", data: 'amenity', group_as: "Social & cultural" }},

        { activity_book_club:          { label: "Book Club/Reading Group", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_computers:          { label: "Computers/Internet", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_current_events:     { label: "Current Events", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_discussion_groups:  { label: "Discussion Groups", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_lectures:           { label: "Lectures", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_music_classes:      { label: "Music Classes", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_technology_classes: { label: "Technology Classes", data: 'amenity', group_as: "Intellectual & educational" }},
        { activity_writing_classes:    { label: "Writing Classes", data: 'amenity', group_as: "Intellectual & educational" }},

        { activity_bible_study:        { label: "Bible Fellowship/Study", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_catholic_mass:      { label: "Catholic Mass/Communion", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_christian_services: { label: "Christian Services", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_hindu_prayer:       { label: "Hindu Prayer", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_meditation:         { label: "Meditation", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_rosary_group:       { label: "Rosary Group", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_shabbat_services:   { label: "Shabbat Services", data: 'amenity', group_as: "Religious & spiritual" }},

        { activity_aquatics:          { label: "Aquatics/Water Aerobics", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_biking:            { label: "Biking", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_bocce:             { label: "Bocce Ball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_bowling:           { label: "Bowling", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_cardio_machines:   { label: "Cardio Machines", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_chair_exercise:    { label: "Chair Exercise", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_dancing:           { label: "Dancing", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_fitness_classes:   { label: "Fitness Classes", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_golf:              { label: "Golf/Putting", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_hiking:            { label: "Hiking", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_horseback:         { label: "Horseback Riding", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_personal_training: { label: "Personal training", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pickleball:        { label: "Pickleball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pilates:           { label: "Pilates", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquet_sports:    { label: "Racquet sports", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquetball:       { label: "Racquetball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_shuffleboard:      { label: "Shuffleboard", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_squash:            { label: "Squash", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_stretching:        { label: "Stretching", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_swimming:          { label: "Swimming", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tai_chi:           { label: "Tai Chi", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tennis:            { label: "Tennis", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_walking_club:      { label: "Walking Club", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_weight_machines:   { label: "Weights/Weight Machines", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_yoga:              { label: "Yoga", data: 'amenity', group_as: "Fitness & Exercise" }},

        { activity_billiards:   { label: "Billiards/Pool", data: 'amenity', group_as: "Games & trivia" }},
        { activity_bingo:       { label: "Bingo", data: 'amenity', group_as: "Games & trivia" }},
        { activity_board_games: { label: "Board Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_bridge:      { label: "Bridge", data: 'amenity', group_as: "Games & trivia" }},
        { activity_card_games:  { label: "Card Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_dominos:     { label: "Dominos", data: 'amenity', group_as: "Games & trivia" }},
        { activity_mahjong:     { label: "Mahjong", data: 'amenity', group_as: "Games & trivia" }},
        { activity_pokeno:      { label: "Pokeno", data: 'amenity', group_as: "Games & trivia" }},
        { activity_poker:       { label: "Poker", data: 'amenity', group_as: "Games & trivia" }},
        { activity_puzzles:     { label: "Puzzles", data: 'amenity', group_as: "Games & trivia" }},
        { activity_trivia:      { label: "Trivia", data: 'amenity', group_as: "Games & trivia" }},
        { activity_video_games: { label: "Video Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_word_games:  { label: "Word Games", data: 'amenity', group_as: "Games & trivia" }},
      ],
    },

    { section: "Food",
      attrs: [
        { food_24h_snacks: { label: "24-Hour Snacks", data: 'amenity', group_as: "Dining style" }},
        { food_3_meals: { label: "3 Meals Daily", data: 'amenity', group_as: "Dining style" }},
        { food_all_day: { label: "Available All Day", data: 'amenity', group_as: "Dining style" }},
        { food_restaurant_style: { label: "Restaurant Style Dining", data: 'amenity', group_as: "Dining style" }},
        { food_room_service: { label: "Room Service", data: 'amenity', group_as: "Dining style" }},
        { food_meal_vouchers: { label: "Meal Vouchers", data: 'amenity', group_as: "Dining style" }},
        { food_guest_meals: { label: "Guest Meals", data: 'amenity', group_as: "Dining style" }},

        { diet_diabetes: { label: "Diabetes Diet", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_foodie_friendly: { label: "Foodie friendly", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_gluten_free: { label: "Gluten-free", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_kosher_meals: { label: "Kosher meals", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_nutrition_conscious: { label: "Nutrition-conscious", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_restricted: { label: "Restricted Diet", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_vegan: { label: "Vegan", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_vegetarian: { label: "Vegetarian", data: 'amenity', group_as: "Dietary accomodations" }},
      ],
    },

    { section: "Services",
      attrs: [
        { services_cable: { label: "Cable Included", data: 'amenity', group_as: "Services" }},
        { services_wifi: { label: "WiFi Included", data: 'amenity', group_as: "Services" }},
        { services_domestic_phone: { label: "Domestic Phone Included", data: 'amenity', group_as: "Services" }},
        { services_concierge: { label: "Concierge", data: 'amenity', group_as: "Services" }},
        { services_housekeeping: { label: "Housekeeping", data: 'amenity', group_as: "Services" }},
        { services_laundry: { label: "Laundry Service", data: 'amenity', group_as: "Services" }},
        { services_linen: { label: "Linen Service", data: 'amenity', group_as: "Services" }},
        { services_hairdresser: { label: "Hairdresser/Barber", data: 'amenity', group_as: "Services" }},
        { services_manicurist: { label: "Manicurist", data: 'amenity', group_as: "Services" }},
        { services_massage: { label: "Massage Therapist", data: 'amenity', group_as: "Services" }},
        { services_shuttle_service: { label: "Car/Shuttle Service", data: 'amenity', group_as: "Services" }},
        { services_transportation: { label: "Transportation Arrangement", data: 'amenity', group_as: "Services" }},
        { services_parking: { label: "Parking", data: 'amenity', group_as: "Services" }},
        { services_valet_parking: { label: "Valet Parking", data: 'amenity', group_as: "Services" }},
      ],
    },

    { section: "Amenitites",
      attrs: [
        { amenity_crafts_room:         { label: "Arts & Crafts Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_bank:                { label: "Bank", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_pub:                 { label: "Bar/Pub", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_billiards_table:     { label: "Billiards/Pool Table", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_cafe:                { label: "Cafe/Bistro", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_chapel:              { label: "Chapel", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_clubhouse:           { label: "Clubhouse", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_common_kitchen:      { label: "Common Kitchen", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_computer_room:       { label: "Computer Room/Area", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_fireplace:           { label: "Fireplaces", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_game_room:           { label: "Game Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_hair_salon:          { label: "Hair Salon/Barber", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_library:             { label: "Library", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_lounge:              { label: "Lounge", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_media_room:          { label: "Media/Film Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_nail_salon:          { label: "Nail Salon", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_piano:               { label: "Piano", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_pharmacy:            { label: "Pharmacy", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_private_dining_room: { label: "Private Dining Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_private_kitchen:     { label: "Private Kitchen", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_restaurant:          { label: "Restaurant", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_spa:                 { label: "Spa", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_store:               { label: "Store", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_sun_room:            { label: "Sun Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_theater:             { label: "Theater", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_meditation_room:     { label: "Wellness/Meditation Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_woodworking_shop:    { label: "Woodworking Shop", data: 'amenity', group_as: "Indoor amenities" }},

        { amenity_walking_paths:           { label: "Walking Paths", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_hiking_trails:           { label: "Hiking Trails", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_biking_trails:           { label: "Biking Trails", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_common_outdoor_space:    { label: "Common Outdoor Space", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_courtyard:               { label: "Courtyard", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_garden:                  { label: "Garden", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_gazebo:                  { label: "Gazebo", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_landscaped_beds:         { label: "Landscaped Beds", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_lawn:                    { label: "Lawn", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_porch:                   { label: "Porch", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_wooded_area:             { label: "Wooded Area", data: 'amenity', group_as: "Outdoor amenities" }},

        { amenitiy_fitness_equipment_room: { label: "Fitness Equipment Room", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_exercise_room:          { label: "Exercise Room", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_fitness_center:         { label: "Fitness Center", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_full_gym:               { label: "Full-Sized Gym", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_athletic_club:          { label: "Athletic Club", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_sauna:                  { label: "Sauna", data: 'amenity', group_as: "Gym facilities" }},
        { amenitiy_steam_room:             { label: "Steam Room", data: 'amenity', group_as: "Gym facilities" }},

        { amenity_indoor_pool:           { label: "Indoor Pool", data: 'amenity', group_as: "Pool" }},
        { amenity_outdoor_pool:          { label: "Outdoor Pool", data: 'amenity', group_as: "Pool" }},
        { amenity_multiple_pools:        { label: "Multiple Pools", data: 'amenity', group_as: "Pool" }},
        { amenity_hot_tub:               { label: "Whirlpool/Hot Tub", data: 'amenity', group_as: "Pool" }},

        { amenity_golf_18hole:           { label: "18-Hole Golf Course", data: 'amenity', group_as: "Golf" }},
        { amenity_gold_9hole:            { label: "9-Hole Golf Course", data: 'amenity', group_as: "Golf" }},
        { amenity_multiple_golf_courses: { label: "Multiple Golf Courses", data: 'amenity', group_as: "Golf" }},
        { amenity_golf_nearby:           { label: "Golf Courses Nearby", data: 'amenity', group_as: "Golf" }},
        { amenity_indoor_driving_range:  { label: "Indoor Driving Range", data: 'amenity', group_as: "Golf" }},
        { amenity_outdoor_driving_range: { label: "Outdoor Driving Range", data: 'amenity', group_as: "Golf" }},
        { amenity_indoor_putting:        { label: "Indoor Putting Area", data: 'amenity', group_as: "Golf" }},
        { amenity_outdoor_putting:       { label: "Outdoor Putting Area", data: 'amenity', group_as: "Golf" }},

        { amenity_pickleball_court:      { label: "Pickleball Court", data: 'amenity', group_as: "Racquet sports" }},
        { amenity_racquetball_court:     { label: "Racquet Ball Court", data: 'amenity', group_as: "Racquet sports" }},
        { amenity_squash_court:          { label: "Squash Court", data: 'amenity', group_as: "Racquet sports" }},
        { amenity_tennis_court:          { label: "Tennis Court", data: 'amenity', group_as: "Racquet sports" }},

        { amenity_bocce_court:           { label: "Bocce Ball Court", data: 'amenity', group_as: "Other sports" }},
        { amenity_bowling_alley:         { label: "Bowling Alley", data: 'amenity', group_as: "Other sports" }},
        { amenity_shuffleboard_court:    { label: "Shuffleboard Court", data: 'amenity', group_as: "Other sports" }},
      ],
    },
  ])
end
