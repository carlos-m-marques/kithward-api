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
        { admin_notes: { label: "Admin Notes", data: 'text', admin_only: true }},
      ],
    },

    { section: "Community Attributes",
      attrs: [
        { star_rating:            { label: "Rating", data: 'rating' }},
        { description:            { label: "Description", data: 'text', direct_model_attribute: true }},
        { religious_affiliation:  { label: "Religious affiliation", data: 'select',
                                    values: [
                                      {'-' => 'None'},
                                      {'B' => "Buddhist"},
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
    
    { section: "Governance & Community Values",
      attrs: [
        { parent_company:                  { label: "Operator", data: 'string', group_as: 'Operator', admin_only: true }},
        
        { ownership_nonprofit_religious:   { label: "Religious Non-Profit", data: 'flag', group_as: 'Ownership' }},
        { ownership_nonprofit_secular:     { label: "Secular Non-Profit", data: 'flag', group_as: 'Ownership' }},
        { ownership_private:               { label: "Privately Held", data: 'flag', group_as: 'Ownership' }},
        { care_oncall_private_equity:      { label: "Private Equity Backed", data: 'flag', group_as: 'Ownership' }},
        { care_onsite_reit:                { label: "REIT", data: 'flag', group_as: 'Ownership' }},
        { care_onsite_public_company:      { label: "Public Company", data: 'flag', group_as: 'Ownership' }},
        
        { resident_council_finances:       { label: "Influences budgeting & financial decisions", data: 'flag', group_as: 'Resident Council' }},
        { resident_council_programming:    { label: "Chooses programming", data: 'flag', group_as: 'Resident Council' }},
        { resident_council_advice:         { label: "Provides advice to management", data: 'flag', group_as: 'Resident Council' }},
        
        { community_values:                { label: "Community Values", data: 'text' }},             
        
        { admin_care_decision_notes:       { label: "Admin Care Decision Notes", data: 'string', admin_only: true }},  
        
        { admin_governance_notes:          { label: "Admin Governance Notes", data: 'text', admin_only: true }},     
        
      ],
    },    
    
    { section: "Resident Profile",
      attrs: [
        { resident_profile_professions:    { label: "Former Professions", data: 'text' }},         
        { resident_profile_interests:      { label: "Interests & Hobbies", data: 'text' }},       
        { resident_profile_cultures:       { label: "Cultural Backgrounds", data: 'text' }},      
        { resident_profile_religions:      { label: "Religions Represented", data: 'text' }},        
        { resident_profile_politics:       { label: "Religious affiliation", data: 'select',
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
        { care_onsite_healthcare:     { label: "Onsite Healthcare", data: 'flag', group_as: 'Healthcare Staff' }},
        
        { care_onsite_doctor_visits:  { label: "Doctor Visits", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_nurse_visits:   { label: "Nurse Visits", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_audiologist:    { label: "Audiologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dentist:        { label: "Dentist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dermatologist:  { label: "Dermatologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_dietician:      { label: "Dietician", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_opthamologist:  { label: "Opthamologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_optometrist:    { label: "Optometrist", data: 'flag', group_as: 'Onsite Healthcare' }},        
        { care_onsite_podiatrist:     { label: "Podiatrist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_psychologist:   { label: "Pschologist", data: 'flag', group_as: 'Onsite Healthcare' }},
        { care_onsite_psychiatrist:   { label: "Psychiatrist", data: 'flag', group_as: 'Onsite Healthcare' }},      

        { security_electronic_key:    { label: "Electronic key entry system", data: 'flag', group_as: 'Security' }},
        { security_emergency_call:    { label: "Emergency call system", data: 'flag', group_as: 'Security' }},
        { security_ft_security:    { label: "Full-Time security", data: 'flag', group_as: 'Security' }},
        { security_inroom_monitoring: { label: "In-room monitoring", data: 'flag', group_as: 'Security' }},
        { security_night_checks:      { label: "Night checks", data: 'flag', group_as: 'Security' }},
        { security_safety_checks:    { label: "Regular safety checks", data: 'flag', group_as: 'Security' }},
        { security_secure_memory: { label: "Secure memory unit", data: 'flag', group_as: 'Security' }},
        { security_security_system:      { label: "Security system", data: 'flag', group_as: 'Security' }},
        { security_staff_background_checks:    { label: "Staff background checks", data: 'flag', group_as: 'Security' }},
        { security_video_surveillance: { label: "Video surveillance", data: 'flag', group_as: 'Security' }},
        { security_visitor_checkins:      { label: "Visitor check-in", data: 'flag', group_as: 'Security' }},

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
        { care_music_therapy:    { label: "Music therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_occupational:      { label: "Occupational therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_parkinsons:        { label: "Parkinsons care", data: 'amenity', group_as: 'Special Care' }},
        { care_physical:          { label: "Physical therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_rehabilitation:    { label: "Rehabilitation program", data: 'amenity', group_as: 'Special Care' }},
        { care_speech:            { label: "Speech therapy", data: 'amenity', group_as: 'Special Care' }},
        { care_wellness:            { label: "Wellness program", data: 'amenity', group_as: 'Special Care' }},
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
        { room_feat_pvt_outdoor:  { label: "Private Outdoor Space", data: 'amenity', group_as: "Room features" }},
        { room_feat_washer:       { label: "Washer/Dryer", data: 'amenity', group_as: "Room features" }},
      ],
    },

    { section: "Activities",
      attrs: [
        { activity_acting:            { label: "Acting/Drama", data: 'amenity', group_as: "Creative" }},
        { activity_arts:              { label: "Arts & Crafts", data: 'amenity', group_as: "Creative" }},
        { activity_ceramics:          { label: "Ceramics/Clay", data: 'amenity', group_as: "Creative" }},
        { activity_comedy:            { label: "Comedy Performance", data: 'amenity', group_as: "Creative" }},
        { activity_cooking:           { label: "Cooking/Baking", data: 'amenity', group_as: "Creative" }},
        { activity_drawing:           { label: "Drawing & Coloring", data: 'amenity', group_as: "Creative" }},
        { activity_floral:            { label: "Flower Arranging", data: 'amenity', group_as: "Creative" }},
        { activity_gardening:         { label: "Gardening", data: 'amenity', group_as: "Creative" }},
        { activity_knitting:          { label: "Knitting/Crocheting", data: 'amenity', group_as: "Creative" }},
        { activity_painting:          { label: "Painting", data: 'amenity', group_as: "Creative" }},
        { activity_poetry:            { label: "Poetry Readings", data: 'amenity', group_as: "Creative" }},
        { activity_singing:           { label: "Singing/Choir", data: 'amenity', group_as: "Creative" }},
        { activity_woodworking:       { label: "Woodworking", data: 'amenity', group_as: "Creative" }},

        { activity_charity:           { label: "Charity/Outreach", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_civic:             { label: "Civic Engagement", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_happy_hour:        { label: "Happy/Social Hour", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_intergenerational: { label: "Intergenerational Activities", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_karaoke:           { label: "Karaoke", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_live_music:        { label: "Live Music/Entertainment", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_mens_club:         { label: "Men's Club", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_movies:            { label: "Movies", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_multicultural:     { label: "Multicultural Activities", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_pet_visits:        { label: "Pet Visits", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_vendors:           { label: "Retail Vendor Visits", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_sharing:           { label: "Sharing/Storytelling", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_travel:            { label: "Travel Club", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_tea_time:          { label: "Tea/Coffee Time", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_watching_sports:   { label: "Watching Sports", data: 'amenity', group_as: "Social & entertainment" }},
        { activity_wine_tasting:      { label: "Wine Tasting", data: 'amenity', group_as: "Social & entertainment" }},

        { activity_casino_trips:      { label: "Casino Trips", data: 'amenity', group_as: "Trips" }},
        { activity_city_trips:        { label: "City Trips", data: 'amenity', group_as: "Trips" }},
        { activity_farmers_market:    { label: "Farmer's Market", data: 'amenity', group_as: "Trips" }},
        { activity_historical:        { label: "Historical/Tourist Attractions", data: 'amenity', group_as: "Trips" }},
        { activity_mall:              { label: "Mall Trips", data: 'amenity', group_as: "Trips" }},
        { activity_museums:           { label: "Museums/Art Galleries", data: 'amenity', group_as: "Trips" }},
        { activity_concerts:          { label: "Music Performances/Concerts", data: 'amenity', group_as: "Trips" }},
        { activity_nature_trips:      { label: "Nature Trips", data: 'amenity', group_as: "Trips" }},
        { activity_dining_out:        { label: "Restaurant Trips", data: 'amenity', group_as: "Trips" }},
        { activity_shopping:          { label: "Shopping/Errands", data: 'amenity', group_as: "Trips" }},
        { activity_sporting_events:   { label: "Sporting Events", data: 'amenity', group_as: "Trips" }},
        { activity_theater:           { label: "Theater/Performing Arts", data: 'amenity', group_as: "Trips" }},
        { activity_wineries:          { label: "Wineries", data: 'amenity', group_as: "Trips" }},        

        { activity_art_classes:        { label: "Art Classes", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_book_club:          { label: "Book Club/Reading Group", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_technology_classes: { label: "Computer Classes", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_current_events:     { label: "Current Events", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_discussion_groups:  { label: "Discussion Groups", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_language_classes:   { label: "Language Classes", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_lectures:           { label: "Lectures", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_lending_program:    { label: "Local Library Lending Program", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_music_appreciation: { label: "Music/Art Appreciation", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_music_classes:      { label: "Music Classes", data: 'amenity', group_as: "Lifelong learning" }},
        { activity_writing_classes:    { label: "Writing Classes", data: 'amenity', group_as: "Lifelong learning" }},

        { activity_bible_study:        { label: "Bible Fellowship/Study", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_catholic_mass:      { label: "Catholic Mass/Communion", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_christian_services: { label: "Christian Services", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_clergy:             { label: "Clergy Visits", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_hindu_prayer:       { label: "Hindu Prayer", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_meditation:         { label: "Meditation", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_nondenominational:  { label: "Non-Denominational Services", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_rabbi_study:        { label: "Rabbi Study Group", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_rosary_group:       { label: "Rosary Group", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_shabbat_services:   { label: "Shabbat Services", data: 'amenity', group_as: "Religious & spiritual" }},
        { activity_church_bus:         { label: "Transportation to Church", data: 'amenity', group_as: "Religious & spiritual" }},

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

        { activity_billiards:   { label: "Billiards/Pool", data: 'amenity', group_as: "Games & trivia" }},
        { activity_bingo:       { label: "Bingo", data: 'amenity', group_as: "Games & trivia" }},
        { activity_board_games: { label: "Board Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_bridge:      { label: "Bridge", data: 'amenity', group_as: "Games & trivia" }},
        { activity_card_games:  { label: "Card Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_dominos:     { label: "Dominos", data: 'amenity', group_as: "Games & trivia" }},
        { activity_mahjong:     { label: "Mahjong", data: 'amenity', group_as: "Games & trivia" }},
        { activity_party_games: { label: "Party Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_pokeno:      { label: "Pokeno", data: 'amenity', group_as: "Games & trivia" }},
        { activity_poker:       { label: "Poker", data: 'amenity', group_as: "Games & trivia" }},
        { activity_puzzles:     { label: "Puzzles", data: 'amenity', group_as: "Games & trivia" }},
        { activity_rummikub:    { label: "Rummikub", data: 'amenity', group_as: "Games & trivia" }},
        { activity_trivia:      { label: "Trivia/Brain Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_video_games: { label: "Video Games", data: 'amenity', group_as: "Games & trivia" }},
        { activity_word_games:  { label: "Word Games", data: 'amenity', group_as: "Games & trivia" }},
      ],
    },

    { section: "Food",
      attrs: [
        { food_24h_snacks: { label: "Snacks Available All Day", data: 'amenity', group_as: "Dining style" }},
        { food_3_meals: { label: "3 Meals Daily", data: 'amenity', group_as: "Dining style" }},
        { food_all_day: { label: "Dining Available All Day", data: 'amenity', group_as: "Dining style" }},
        { food_restaurant_style: { label: "Restaurant Style Dining", data: 'amenity', group_as: "Dining style" }},
        { food_room_service: { label: "Room Service", data: 'amenity', group_as: "Dining style" }},
        { food_meal_vouchers: { label: "Meal Vouchers", data: 'amenity', group_as: "Dining style" }},
        { food_guest_meals: { label: "Guest Meals", data: 'amenity', group_as: "Dining style" }},

        { diet_foodie_friendly: { label: "Chef-Prepared", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_gluten_free: { label: "Gluten-Free", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_kosher_meals: { label: "Kosher Meals", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_restricted: { label: "Restricted Diet", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_vegan: { label: "Vegan", data: 'amenity', group_as: "Dietary accomodations" }},
        { diet_vegetarian: { label: "Vegetarian", data: 'amenity', group_as: "Dietary accomodations" }},
      ],
    },

    { section: "Available Services",
      attrs: [
        { services_cable: { label: "Cable Included", data: 'amenity', group_as: "Utilities" }},
        { services_domestic_phone: { label: "Domestic Phone Included", data: 'amenity', group_as: "Utilities" }},
        { services_wifi: { label: "WiFi Included", data: 'amenity', group_as: "Utilities" }},
        { services_wifi_common: { label: "WiFi In Common Areas", data: 'amenity', group_as: "Utilities" }},

        { services_chaplain: { label: "Chaplain/Priest", data: 'amenity', group_as: "Services" }},
        { services_concierge: { label: "Dry-cleaning Services", data: 'amenity', group_as: "Services" }},
        { services_drycleaning: { label: "Concierge", data: 'amenity', group_as: "Services" }},
        { services_hairdresser: { label: "Hairdresser/Barber", data: 'amenity', group_as: "Services" }},
        { services_housekeeping: { label: "Housekeeping", data: 'amenity', group_as: "Services" }},
        { services_laundry: { label: "Laundry Service", data: 'amenity', group_as: "Services" }},
        { services_linen: { label: "Linen Service", data: 'amenity', group_as: "Services" }},
        { services_manicurist: { label: "Manicurist", data: 'amenity', group_as: "Services" }},
        { services_massage: { label: "Massage Therapist", data: 'amenity', group_as: "Services" }},
        { services_newspaper: { label: "Newspaper Delivery", data: 'amenity', group_as: "Services" }},
        { services_pharmacy: { label: "Pharmacy Services", data: 'amenity', group_as: "Services" }},
        { services_catering: { label: "Private Event Catering", data: 'amenity', group_as: "Services" }}, 
        { services_rabbi: { label: "Rabbi", data: 'amenity', group_as: "Services" }},
        
        { services_shuttle_service: { label: "Car/Shuttle Service", data: 'amenity', group_as: "Transportation & Parking" }},        
        { services_parking: { label: "Parking", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_scheduled_transport: { label: "Scheduled Transportation", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_transportation: { label: "Transportation Arrangement", data: 'amenity', group_as: "Transportation & Parking" }},
        { services_valet_parking: { label: "Valet Parking", data: 'amenity', group_as: "Transportation & Parking" }},
      ],
    },

    { section: "Amenitites",
      attrs: [
        { amenity_crafts_room:         { label: "Arts & Crafts Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_bank:                { label: "Bank", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_pub:                 { label: "Bar/Pub", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_billiards_table:     { label: "Billiards/Pool Table", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_cafe:                { label: "Cafe/Bistro", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_chapel:              { label: "Chapel/Religious Services Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_clubhouse:           { label: "Clubhouse", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_common_kitchen:      { label: "Common Kitchen", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_computer_room:       { label: "Computer Room/Area", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_fireplace:           { label: "Fireplaces", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_game_room:           { label: "Game/Card Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_hair_salon:          { label: "Hair Salon/Barber", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_laundry:             { label: "Laundry Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_library:             { label: "Library", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_lounge:              { label: "Lounge/Community Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_media_room:          { label: "Media/Film Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_meditation_room:     { label: "Meditation/Prayer Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_theater:             { label: "Movie Theater", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_music_room:          { label: "Music Room/Conservatory", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_nail_salon:          { label: "Nail Salon", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_guest_suite:         { label: "Overnight Guest Suite", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_piano:               { label: "Piano", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_pharmacy:            { label: "Pharmacy", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_private_dining_room: { label: "Private Dining Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_private_kitchen:     { label: "Private Kitchen", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_restaurant:          { label: "Restaurant", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_spa:                 { label: "Spa", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_stage:               { label: "Stage/Theater", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_store:               { label: "Store", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_sun_room:            { label: "Sun Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_tea_room:            { label: "Tea/Coffee Room", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_vending_machines:    { label: "Vending Machines", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_wellness_center:     { label: "Wellness Center", data: 'amenity', group_as: "Indoor amenities" }},
        { amenity_woodworking_shop:    { label: "Woodworking Shop", data: 'amenity', group_as: "Indoor amenities" }},

        { amenity_walking_paths:           { label: "Walking Paths", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_hiking_trails:           { label: "Hiking Trails", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_biking_trails:           { label: "Biking Trails", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_courtyard:               { label: "Courtyard", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_fountain:                { label: "Fountain/Water Features", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_garden:                  { label: "Garden", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_gazebo:                  { label: "Gazebo", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_greenhouse:              { label: "Greenhouse", data: 'amenity', group_as: "Outdoor amenities" }},        
        { amenity_landscaped:              { label: "Landscaped Grounds", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_lawn:                    { label: "Lawn", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_grill:                   { label: "Outdoor Grill", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_outdoor_dining:          { label: "Outdoor Dining Area", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_pond:                    { label: "Pond/Lake", data: 'amenity', group_as: "Outdoor amenities" }},
        { amenity_porch:                   { label: "Porch/Patio", data: 'amenity', group_as: "Outdoor amenities" }},
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
