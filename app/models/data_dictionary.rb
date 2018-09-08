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
                          {'A' => "Assisted living"},
                          {'I' => "Independent Living"},
                          {'S' => "Skilled nursing"},
                          {'M' => "Memory care"},
                        ]}},

        { ccrc:   { label: "Continuing care community", data: 'flag' }},
        { aip:    { label: "Aging in place", data: 'flag' }},

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

        { description:            { label: "Description", data: 'text', direct_model_attribute: true }},
        { admin_notes: { label: "Admin Notes", data: 'text', admin_only: true }},

        { star_rating:            { label: "Rating", data: 'rating' }},

        { community_size:         { label: "Community size", data: 'select',
                                     values: [
                                       {'S' => 'Small'},
                                       {'M' => 'Medium'},
                                       {'L' => 'Large'},
                                    ]}},
        { bed_count:              { label: "Beds", data: 'count'}},
        { staff_total:            { label: "Total staff", data: 'count' }},
        { staff_full_time:        { label: "Full-time staff", data: 'count' }},
        { staff_ratio:            { label: "Staff to resident ratio", data: 'number'}},

        { setting:                { label: "Setting", data: 'select',
                                    values: [
                                      {'U' => "Urban"},
                                      {'S' => "Suburban"},
                                      {'R' => "Rural"},
                                    ]}},

        { religious_affiliation:  { label: "Religious affiliation", data: 'select',
                                    values: [
                                      {'-' => 'None'},
                                      {'B' => "Buddhist"},
                                      {'C' => "Catholic"},
                                      {'X' => "Christian"},
                                      {'J' => "Jewish"},
                                      {'L' => "Lutheran"},
                                      {'Q' => "Quaker"},
                                      {'O' => "Other"},
                                    ]}},
        { lgbt_friendly:          { label: "LGBTQ focus", data: 'flag' }},

        { access_to_city:         { label: "Access to the city", data: 'flag' }},
        { access_to_outdoors:     { label: "Access to the outdoors", data: 'flag' }},

        { smoking:                { label: "Smoking", data: 'flag' }},
        { non_smoking:            { label: "Non-smoking", data: 'flag' }},
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
      desc: "Here are the various accomodations available to choose from, subject to availability. " \
            "There may be more options than what are shown. Contact us to find out more.",
      attrs: [
        { room_shared:            { label: "Shared Room", data: 'amenity', group_as: "Room Types" }},
        { room_private:           { label: "Private Room", data: 'amenity', group_as: "Room Types" }},
        { room_studio:            { label: "Studio", data: 'amenity', group_as: "Room Types" }},
        { room_one_bed:           { label: "1 bedroom", data: 'amenity', group_as: "Room Types" }},
        { room_two_plus:          { label: "2 Bedrooms +", data: 'amenity', group_as: "Room Types" }},
        { room_dettached:         { label: "Detached home", data: 'amenity', group_as: "Room Types" }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group_as: "Room Features" }},
        { room_feat_custom:       { label: "Custom Renovations Available", data: 'amenity', group_as: "Room Features" }},
        { room_feat_den:          { label: "Den/Extra Room", data: 'amenity', group_as: "Room Features" }},
        { room_feat_kitchen:      { label: "Full Kitchen", data: 'amenity', group_as: "Room Features" }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group_as: "Room Features" }},
        { room_feat_dishwasher:   { label: "Dishwasher", data: 'amenity', group_as: "Room Features" }},
        { room_feat_climate:      { label: "Individual Climate Control", data: 'amenity', group_as: "Room Features" }},
        { room_feat_pvt_outdoor:  { label: "Private Outdoor Space", data: 'amenity', group_as: "Room Features" }},
        { room_feat_walkin:       { label: "Walk-In Closets", data: 'amenity', group_as: "Room Features" }},
        { room_feat_washer:       { label: "Washer/Dryer", data: 'amenity', group_as: "Room Features" }},

        { room_floorplans:        { label: "Floorplans", special: 'thumbnails', tagged_as: 'floorplan'}},
      ],
    },

    { section: "Pricing Summary",
      desc: "Pricing can vary greatly depending on the accomodations you are looking for and the " \
            "level of assistance you require, if any. Contact us to find out more.",
      attrs: [
        { price_rating:           { label: "Price rating", data: 'rating', admin_break_after: 'yes' }},

        { rent_starting_price:    { label: "Base rent starting price", data: 'price' }},
        { rent_maximum_price:     { label: "Base rent maximum price", data: 'price' }},
        { rent_includes_care:     { label: "Base rent includes care price", data: 'flag', admin_break_after: 'yes' }},

        { care_starting_price:    { label: "Care cost starting price", data: 'price' }},
        { care_maximum_price:     { label: "Care cost maximum price", data: 'price', admin_break_after: 'yes' }},

        { entrance_fee_min:       { label: "Minimum entrance fee", data: 'price' }},
        { entrance_fee_max:       { label: "Maximum entrance fee", data: 'price', admin_break_after: 'yes' }},

        { public_pricing_notes:   { label: "Additional Pricing Information", data: 'text' }},
        { admin_pricing_notes:    { label: "Admin Pricing Notes", data: 'text', admin_only: true }},

      ]
    },

    { section: "Care & Assistance",
      desc: "Here are the types of healthcare and assistance offered at this community, some of which " \
            "may come at an additional cost.",
      attrs: [
        { staff_doctors:              { label: "Doctors", data: 'count' }},
        { staff_doctors_ft:           { label: "Full-time doctors", data: 'count' }},
        { staff_nurses:               { label: "Licensed nurses", data: 'count' }},
        { staff_nurses_ft:            { label: "Full-time licensed nurses", data: 'count' }},
        { staff_socworkers:           { label: "Licensed social workers", data: 'count' }},
        { staff_socworkers_ft:        { label: "Full-time licensed social workers", data: 'count' }},

        { care_ft_doctor:             { label: "Full-Time In House Doctor", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_ft_nurse:              { label: "Full-Time In House Nurse", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_247_nurse:             { label: "Full-Time In House Nurse (24/7)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_RN:                    { label: "Registered Nurse(s)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_LPN:                   { label: "Licensed Practical Nurse(s)", data: 'flag', group_as: 'Healthcare Staff' }},
        { care_social_worker:         { label: "Social Worker(s)", data: 'flag', group_as: 'Healthcare Staff' }},

        { care_onsite_doctor_visits:  { label: "Doctor Visits", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_nurse_visits:   { label: "Nurse Visits", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_audiologist:    { label: "Audiologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_cardiologist:   { label: "Cardiologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dentist:        { label: "Dentist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dermatologist:  { label: "Dermatologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dietician:      { label: "Dietician", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_opthamologist:  { label: "Opthamologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_optometrist:    { label: "Optometrist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_podiatrist:     { label: "Podiatrist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_psychologist:   { label: "Psychologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_psychiatrist:   { label: "Psychiatrist", data: 'flag', group_as: 'Onsite Healthcare' }},


        { assistance_bathing:     { label: "Bathing",   data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_dressing:    { label: "Dressing",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_errands:     { label: "Errands/escort",   data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_grooming:    { label: "Grooming",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_medication:  { label: "Medication Management", data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_mobility:    { label: "Mobility",  data: 'amenity', group_as: 'Personal Assistance' }},
        { assistance_toileting:   { label: "Toileting", data: 'amenity', group_as: 'Personal Assistance' }},

        { care_dementia:          { label: "Alzheimer's/Dementia Care", data: 'amenity', group_as: 'Special Care' }},
        { care_diabetes:          { label: "Diabetes Care", data: 'amenity', group_as: 'Special Care' }},
        { care_incontinence:      { label: "Incontinence Care", data: 'amenity', group_as: 'Special Care' }},
        { care_urinary:           { label: "Incontinence Care (Urinary only)", data: 'amenity', group_as: 'Special Care' }},
        { care_mild_cognitive:    { label: "Mild Cognitive Impairment Care", data: 'amenity', group_as: 'Special Care' }},
        { care_music_therapy:     { label: "Music therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_occupational:      { label: "Occupational therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_parkinsons:        { label: "Parkinsons care", data: 'amenity', group_as: 'Special Care' }},
        { care_physical:          { label: "Physical therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_rehabilitation:    { label: "Rehabilitation program", data: 'amenity', group_as: 'Special Care' }},
        { care_speech:            { label: "Speech therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_wellness:          { label: "Wellness program", data: 'amenity', group_as: 'Special Care' }},
      ],
    },

    { section: "Dining & Diet",
      desc: "Here you will find the style of dining in the community, as well as the types of diets " \
            "they can accomodate. If you have special restrictions, contact us to find out more.",
      attrs: [
        { food_24h_snacks:        { label: "Snacks Available All Day", data: 'amenity', group_as: "Dining Style" }},
        { food_3_meals:           { label: "3 Meals Daily", data: 'amenity', group_as: "Dining Style" }},
        { food_all_day:           { label: "Dining Available All Day", data: 'amenity', group_as: "Dining Style" }},
        { food_restaurant_style:  { label: "Restaurant Style Dining", data: 'amenity', group_as: "Dining Style" }},
        { food_room_service:      { label: "Room Service", data: 'amenity', group_as: "Dining Style" }},
        { food_meal_vouchers:     { label: "Meal Plans/Vouchers", data: 'amenity', group_as: "Dining Style" }},
        { food_guest_meals:       { label: "Guest Meals", data: 'amenity', group_as: "Dining Style" }},

        { diet_foodie_friendly:   { label: "Chef-Prepared", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_restricted:        { label: "Restricted Diets", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_gluten_free:       { label: "Gluten-Free", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_kosher_meals:      { label: "Kosher Meals", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_vegan:             { label: "Vegan", data: 'amenity', group_as: "Dietary Accomodations" }},
        { diet_vegetarian:        { label: "Vegetarian", data: 'amenity', group_as: "Dietary Accomodations" }},

        { food_menus:             { label: "Sample Menus", special: 'thumbnails', tagged_as: 'menu'}},
      ],
    },

    { section: "Available Services",
      desc: "Here are the services offered in the community, though some may come with an additional " \
            "cost or be subject to availability.",
      attrs: [
        { services_banking:      { label: "Banking Services", data: 'amenity', group_as: "Services" }},
        { services_chaplain:     { label: "Chaplain/Priest", data: 'amenity', group_as: "Services" }},
        { services_concierge:    { label: "Dry-Cleaning Services", data: 'amenity', group_as: "Services" }},
        { services_drycleaning:  { label: "Concierge", data: 'amenity', group_as: "Services" }},
        { services_hairdresser:  { label: "Hairdresser/Barber", data: 'amenity', group_as: "Services" }},
        { services_housekeeping: { label: "Housekeeping", data: 'amenity', group_as: "Services" }},
        { services_laundry:      { label: "Laundry Service", data: 'amenity', group_as: "Services" }},
        { services_linen:        { label: "Linen Service", data: 'amenity', group_as: "Services" }},
        { services_manicurist:   { label: "Manicurist", data: 'amenity', group_as: "Services" }},
        { services_massage:      { label: "Massage Therapist", data: 'amenity', group_as: "Services" }},
        { services_newspaper:    { label: "Newspaper Delivery", data: 'amenity', group_as: "Services" }},
        { services_volunteers:   { label: "Outside Volunteers", data: 'amenity', group_as: "Services" }},
        { services_pharmacy:     { label: "Pharmacy Services", data: 'amenity', group_as: "Services" }},
        { services_catering:     { label: "Private Event Catering", data: 'amenity', group_as: "Services" }},
        { services_rabbi:        { label: "Rabbi", data: 'amenity', group_as: "Services" }},

        { services_shuttle_service: { label: "Car/Shuttle Service", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_parking: { label: "Parking", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_scheduled_transport: { label: "Scheduled Transportation", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_transportation: { label: "Transportation Arrangement", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_valet_parking: { label: "Valet Parking", data: 'amenity', group_as: "Transportation & Parking" }},

        { services_cable: { label: "Cable Included", data: 'amenity', group_as: "Included Utilities" }},
        { services_domestic_phone: { label: "Domestic Phone Included", data: 'amenity', group_as: "Included Utilities" }},
        { services_wifi: { label: "WiFi Included", data: 'amenity', group_as: "Included Utilities" }},
        { services_wifi_common: { label: "WiFi In Common Areas", data: 'amenity', group_as: "Included Utilities" }},

      ],
    },

    { section: "Activities",
      desc: "Activity calendars speak volumes about the culture of a community. Here you'll learn " \
            "what opportunities there are to socialize, stay fit, be creative, stay engages, grow " \
            "spiritually, and more.",
      attrs: [
        { activity_acting:            { label: "Acting/Drama", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_arts:              { label: "Arts & Crafts", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_ceramics:          { label: "Ceramics/Clay", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_chimes:            { label: "Chimes/Bell Choir", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_comedy:            { label: "Comedy Performance", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_cooking:           { label: "Cooking/Baking", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_drawing:           { label: "Drawing & Coloring", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_floral:            { label: "Flower Arranging", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_gardening:         { label: "Gardening", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_knitting:          { label: "Knitting/Crocheting", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_painting:          { label: "Painting", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_poetry:            { label: "Poetry Readings", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_singing:           { label: "Singing/Choir", data: 'amenity', group_as: "Creative & Artistic" }},
        { activity_woodworking:       { label: "Woodworking", data: 'amenity', group_as: "Creative & Artistic" }},

        { activity_charity:           { label: "Charity/Outreach", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_civic:             { label: "Civic Engagement", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_happy_hour:        { label: "Happy/Social Hour", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_intergenerational: { label: "Intergenerational Activities", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_karaoke:           { label: "Karaoke", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_live_music:        { label: "Live Music/Entertainment", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_mens_club:         { label: "Men's Club", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_movies:            { label: "Movies", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_multicultural:     { label: "Multicultural Activities", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_pet_visits:        { label: "Pet Visits", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_vendors:           { label: "Retail Vendor Visits", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_sharing:           { label: "Sharing/Storytelling", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_travel:            { label: "Travel Club", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_tea_time:          { label: "Tea/Coffee Time", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_watching_sports:   { label: "Watching Sports", data: 'amenity', group_as: "Social & Entertainment" }},
        { activity_wine_tasting:      { label: "Wine Tasting", data: 'amenity', group_as: "Social & Entertainment" }},

        { activity_casino_trips:      { label: "Casino Trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_city_trips:        { label: "City Trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_farmers_market:    { label: "Farmer's Market", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_historical:        { label: "Historical/Tourist Attractions", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_mall:              { label: "Mall Trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_museums:           { label: "Museums/Art Galleries", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_concerts:          { label: "Music Performances/Concerts", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_nature_trips:      { label: "Nature Trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_dining_out:        { label: "Restaurant Trips", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_shopping:          { label: "Shopping/Errands", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_sporting_events:   { label: "Sporting Events", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_theater:           { label: "Theater/Performing Arts", data: 'amenity', group_as: "Trips & Outings" }},
        { activity_wineries:          { label: "Wineries", data: 'amenity', group_as: "Trips & Outings" }},

        { activity_art_classes:        { label: "Art Classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_book_club:          { label: "Book Club/Reading Group", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_technology_classes: { label: "Computer Classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_current_events:     { label: "Current Events", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_discussion_groups:  { label: "Discussion Groups", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_language_classes:   { label: "Language Classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_lectures:           { label: "Lectures/Classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_lending_program:    { label: "Local Library Lending Program", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_music_appreciation: { label: "Music/Art Appreciation", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_music_classes:      { label: "Music Classes", data: 'amenity', group_as: "Lifelong Learning" }},
        { activity_writing_classes:    { label: "Writing Classes", data: 'amenity', group_as: "Lifelong Learning" }},

        { activity_bible_study:        { label: "Bible Fellowship/Study", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_catholic_mass:      { label: "Catholic Mass/Communion", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_christian_services: { label: "Christian Services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_clergy:             { label: "Clergy Visits", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_episcopal:          { label: "Episcopal Services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_hindu_prayer:       { label: "Hindu Prayer", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_meditation:         { label: "Meditation", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_nondenominational:  { label: "Non-Denominational Services/Faith Group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_quaker_services:    { label: "Quaker Services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_rabbi_study:        { label: "Rabbi Study Group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_rosary_group:       { label: "Rosary Group", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_shabbat_services:   { label: "Shabbat Services", data: 'amenity', group_as: "Religious & Spiritual" }},
        { activity_church_bus:         { label: "Transportation to Church", data: 'amenity', group_as: "Religious & Spiritual" }},

        { activity_aquatics:          { label: "Aquatics/Water Aerobics", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_balance:           { label: "Balance/Stability", data: 'amenity', group_as: "Fitness & Exercise" }},
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
        { activity_lawn_games:        { label: "Lawn Games", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_personal_training: { label: "Personal training", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pickleball:        { label: "Pickleball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_pilates:           { label: "Pilates", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquet_sports:    { label: "Racquet sports", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_racquetball:       { label: "Racquetball", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_shuffleboard:      { label: "Shuffleboard", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_squash:            { label: "Squash", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_strength:          { label: "Strength Training", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_stretching:        { label: "Stretching", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_swimming:          { label: "Swimming", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tai_chi:           { label: "Tai Chi", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_tennis:            { label: "Tennis", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_walking_club:      { label: "Walking Club", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_yoga:              { label: "Yoga", data: 'amenity', group_as: "Fitness & Exercise" }},
        { activity_zumba:             { label: "Zumba", data: 'amenity', group_as: "Fitness & Exercise" }},

        { activity_billiards:   { label: "Billiards/Pool", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_bingo:       { label: "Bingo", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_board_games: { label: "Board Games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_bridge:      { label: "Bridge", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_card_games:  { label: "Card Games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_dominos:     { label: "Dominos", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_mahjong:     { label: "Mahjong", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_party_games: { label: "Party Games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_pokeno:      { label: "Pokeno", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_poker:       { label: "Poker", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_puzzles:     { label: "Puzzles", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_rummikub:    { label: "Rummikub", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_trivia:      { label: "Trivia/Brain Games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_video_games: { label: "Video Games", data: 'amenity', group_as: "Games & Trivia" }},
        { activity_word_games:  { label: "Word Games", data: 'amenity', group_as: "Games & Trivia" }},

        { activity_calendars:   { label: "Sample Calendars", special: 'thumbnails', tagged_as: 'calendar'}},
      ],
    },

    { section: "Amenities",
      desc: "These are the amenities that represent the 'bones' of the community: the rooms, " \
            "facilities, features and infrastructure meant to enhance and enrich the lives of the residents.",
      attrs: [
        { amenity_ATM:                 { label: "ATM", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_crafts_room:         { label: "Arts & Crafts Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_bank:                { label: "Bank", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_pub:                 { label: "Bar/Pub", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_billiards_table:     { label: "Billiards/Pool Table", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_cafe:                { label: "Cafe/Bistro", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_chapel:              { label: "Chapel/Worship Space", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_classroom:           { label: "Classroom/Lecture Hall", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_walkways:            { label: "Climate-Controlled Walkways", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_clubhouse:           { label: "Clubhouse", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_common_kitchen:      { label: "Common Kitchen", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_computer_room:       { label: "Computer Room/Area", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_fireplace:           { label: "Fireplaces", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_game_room:           { label: "Game/Card Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_hair_salon:          { label: "Hair Salon/Barber", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_laundry:             { label: "Laundry Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_library:             { label: "Library", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_lounge:              { label: "Lounge/Community Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_media_room:          { label: "Media/Film Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_meditation_room:     { label: "Meditation/Prayer Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_theater:             { label: "Movie Theater", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_music_room:          { label: "Music Room/Conservatory", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_nail_salon:          { label: "Nail Salon", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_guest_suite:         { label: "Overnight Guest Suite", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_piano:               { label: "Piano", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_pharmacy:            { label: "Pharmacy", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_private_dining_room: { label: "Private Dining Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_private_kitchen:     { label: "Private Kitchen", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_restaurant:          { label: "Restaurant", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_spa:                 { label: "Spa", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_stage:               { label: "Stage/Theater", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_store:               { label: "Store", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_sun_room:            { label: "Sun Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_tea_room:            { label: "Tea/Coffee Room", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_vending_machines:    { label: "Vending Machines", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_wellness_center:     { label: "Wellness Center", data: 'amenity', group_as: "Indoor Amenities" }},
        { amenity_woodworking_shop:    { label: "Woodworking Shop", data: 'amenity', group_as: "Indoor Amenities" }},

        { amenity_walking_paths:           { label: "Walking Paths", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_hiking_trails:           { label: "Hiking Trails", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_biking_trails:           { label: "Biking Trails", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_courtyard:               { label: "Courtyard", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_fountain:                { label: "Fountain/Water Feature", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_garden:                  { label: "Garden", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_gazebo:                  { label: "Gazebo", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_greenhouse:              { label: "Greenhouse", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_landscaped:              { label: "Landscaped Grounds", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_lawn:                    { label: "Lawn", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_grill:                   { label: "Outdoor Grill", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_outdoor_dining:          { label: "Outdoor Dining Area", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_pond:                    { label: "Pond/Lake", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_porch:                   { label: "Porch/Patio", data: 'amenity', group_as: "Outdoor Amenities" }},
        { amenity_wooded_area:             { label: "Wooded Area", data: 'amenity', group_as: "Outdoor Amenities" }},

        { amenitiy_fitness_equipment_room: { label: "Fitness Equipment Room", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_exercise_room:          { label: "Exercise Room", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_fitness_center:         { label: "Fitness Center", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_full_gym:               { label: "Full-Sized Gym", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_athletic_club:          { label: "Athletic Club", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_sauna:                  { label: "Sauna", data: 'amenity', group_as: "Gym Facilities" }},
        { amenitiy_steam_room:             { label: "Steam Room", data: 'amenity', group_as: "Gym Facilities" }},

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

        { amenity_pickleball_court:      { label: "Pickleball Court", data: 'amenity', group_as: "Racquet Sports" }},
        { amenity_ping_pong:             { label: "Ping Pong", data: 'amenity', group_as: "Racquet Sports" }},
        { amenity_racquetball_court:     { label: "Racquet Ball Court", data: 'amenity', group_as: "Racquet Sports" }},
        { amenity_squash_court:          { label: "Squash Court", data: 'amenity', group_as: "Racquet Sports" }},
        { amenity_tennis_court:          { label: "Tennis Court", data: 'amenity', group_as: "Racquet Sports" }},

        { amenity_bocce_court:           { label: "Bocce Ball Court", data: 'amenity', group_as: "Other Sports" }},
        { amenity_bowling_alley:         { label: "Bowling Alley", data: 'amenity', group_as: "Other Sports" }},
        { amenity_shuffleboard_court:    { label: "Shuffleboard Court", data: 'amenity', group_as: "Other Sports" }},
      ],
    },

    { section: "Security",
      desc: "Here are the things this community has put in place to ensure its residents are safe and secure.",
      attrs: [
        { security_electronic_key:             { label: "Electronic key entry system", data: 'flag', group_as: 'Security' }},
        { security_emergency_pendant:          { label: "Emergency alert pendants", data: 'flag', group_as: 'Security' }},
        { security_ft_security:                { label: "Full-Time Security Staff", data: 'flag', group_as: 'Security' }},
        { security_emergency_call:             { label: "In-room emergency call system", data: 'flag', group_as: 'Security' }},
        { security_night_checks:               { label: "Night checks", data: 'flag', group_as: 'Security' }},
        { security_safety_checks:              { label: "Regular safety checks", data: 'flag', group_as: 'Security' }},
        { security_secure_memory:              { label: "Secure memory unit", data: 'flag', group_as: 'Security' }},
        { security_security_system:            { label: "Security system", data: 'flag', group_as: 'Security' }},
        { security_staff_background_checks:    { label: "Staff background checks", data: 'flag', group_as: 'Security' }},
        { security_video_surveillance:         { label: "Video surveillance", data: 'flag', group_as: 'Security' }},
        { security_visitor_checkins:           { label: "Visitor check-in", data: 'flag', group_as: 'Security' }},

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
