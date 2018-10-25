class DataDictionary
  attr_reader :spec

  def initialize(spec)
    @spec = spec
  end

  def validate
    (sections and sections.size > 0) or raise "The specification cannot be empty"

    sections.each {|section|
      (section.has_key?(:section) and section.has_key?(:label) and section.has_key?(:attrs) and section[:attrs].size > 0) \
      or raise "Sections need an id, a label and attributes"
    }

    repeated_ids = sections.collect {|s| s[:section]}.group_by(&:itself).select {|k, v| v.size > 1}
    repeated_ids.length == 0 or raise "Sections need unique ids (#{repeated_ids.collect {|k, v| k}.join(", ")})"

    all_attrs = spec.collect {|section| section[:attrs]}.flatten

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
    @attributes ||= spec.collect {|section| section[:attrs]}.flatten.collect {|a| [a.keys.first, a.values.first&.with_indifferent_access]}.to_h.with_indifferent_access
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

  #================================================================================================
  Community = self.new([
    { section: 'details',
      label: "Community Details",
      groups: [
        { basics: {}},
        { related: {}},
        { contact: {}},
        { characteristics: {}},
        { admin: {}},
      ],
      attrs: [
        { name:   { label: "Community name", data: 'string', direct_model_attribute: true, group: 'basics', }},
        { care_type:  { label: "Community type", data: 'select', direct_model_attribute: true, group: 'basics',
                        values: [
                          {'A' => "Assisted Living"},
                          {'I' => "Independent Living"},
                          {'S' => "Skilled Nursing"},
                          {'M' => "Memory Care"},
                        ]}},

        { ccrc:   { label: "Continuing Care Retirement Community", data: 'flag', group: 'basics', }},
        { aip:    { label: "Allows 'aging in place'", data: 'flag', group: 'basics', }},

        { star_rating:  { label: "Service Level", data: 'rating', group: 'basics' }},

        { related_communities:  { label: "Related Communities", data: 'list_of_ids', admin_only: true, group: 'related'}},

        { phone: { label: "Phone", data: 'phone', group: 'contact' }},
        { email: { label: "Email", data: 'email', group: 'contact' }},
        { fax:   { label: "Fax", data: 'fax', group: 'contact' }},
        { web:   { label: "Web site", data: 'url', group: 'contact' }},

        { street: { label: "Address", data: 'string', direct_model_attribute: true, group: 'contact' }},
        { street_more: { label: "", data: 'string', direct_model_attribute: true, group: 'contact'  }},
        { city: { label: "City", data: 'string', direct_model_attribute: true, group: 'contact'  }},
        { state: { label: "State", data: 'string', direct_model_attribute: true, group: 'contact'  }},
        { postal: { label: "ZIP", data: 'string', direct_model_attribute: true, group: 'contact'  }},
        { country: { label: "Country", data: 'string', direct_model_attribute: true, group: 'contact'  }},

        { description:            { label: "Description", data: 'text', direct_model_attribute: true, group: 'basics', }},
        { admin_notes: { label: "Admin Notes", data: 'text', admin_only: true, group: 'admin', }},

        { community_size:         { label: "Community Size", data: 'select', group: 'characteristics',
                                     values: [
                                       {'S' => 'Small'},
                                       {'M' => 'Medium-sized'},
                                       {'L' => 'Large'},
                                    ]}},
        { bed_count:              { label: "Total Beds", data: 'count', group: 'characteristics', }},

        { staff_total:            { label: "Total Staff", data: 'count', group: 'characteristics', }},
        { staff_full_time:        { label: "Full-Time Staff", data: 'count', group: 'characteristics', }},
        { staff_ratio:            { label: "Staff to Resident Ratio", data: 'number', group: 'characteristics' }},

        { setting:                { label: "Setting", data: 'select', group: 'characteristics',
                                    values: [
                                      {'U' => "Urban setting"},
                                      {'S' => "Suburban setting"},
                                      {'R' => "Rural setting"},
                                    ]}},
        { access_to_city:         { label: "Access to the city", data: 'flag', group: 'characteristics', }},
        { access_to_outdoors:     { label: "Access to the outdoors", data: 'flag', group: 'characteristics', }},

        { religious_affiliation:  { label: "Religious affiliation", data: 'select', group: 'characteristics',
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
        { lgbt_friendly:          { label: "LGBTQ focus", data: 'flag', group: 'characteristics', }},

        { smoking:                { label: "Smoking allowed", data: 'flag', group: 'characteristics', }},
        { non_smoking:            { label: "Smoking prohibited", data: 'flag', group: 'characteristics', }},

        { pet_friendly:           { label: "Pet-friendly", data: 'flag', group: 'characteristics', }},
        { pet_policy:             { label: "Pet policy", data: 'string', group: 'characteristics', }},

        { completeness:           { label: "Completeness", data: 'select', group: 'admin',
                                    admin_only: true,
                                    values: [
                                      {'0' =>  "Incomplete"},
                                      {'30' => "Somewhat complete"},
                                      {'60' => "Very complete"},
                                      {'90' => "Complete"},
                                    ]}},
        { needs_review:           { label: "Needs review", data: 'flag', admin_only: true, group: 'admin', }},
        { last_visited:           { label: "Last Visited", data: 'string', admin_only: true, group: 'admin', }},

        { community_map:          { label: "Community Map", data: 'thumbnails', special: true, tagged_as: 'map', group: 'basics',}},

      ]
    },

    { section: 'kithward',
      label: "Kithward Color",
      attrs: [
        { kithward_color:         { label: "Kithward Color", data: 'text' }},
        { kithward_color_y:       { label: "Display Kithward Color", data: 'flag' }},
      ],
    },

    { section: 'accomodations',
      label: "Accomodations",
      desc: "Here are the various types of units available to choose from, subject to availability. " \
            "There may be more options than what are shown. Contact us to find out more.",
      groups: [
        { units: { label: "Apartment Sizes"}},
        { features: { label: "Available Features"}},
        { floorplans: { label: "-Floorplans" }},
      ],
      attrs: [
        { room_shared:            { label: "Shared room", data: 'amenity', group: 'units' }},
        { room_private:           { label: "Private room", data: 'amenity', group: 'units' }},
        { room_companion:         { label: "Shared suite", data: 'amenity', group: 'units' }},
        { room_studio:            { label: "Studio", data: 'amenity', group: 'units' }},
        { room_one_bed:           { label: "1 bedroom", data: 'amenity', group: 'units' }},
        { room_two_plus:          { label: "2 bedrooms +", data: 'amenity', group: 'units' }},
        { room_detached:          { label: "Detached home", data: 'amenity', group: 'units' }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group: 'features' }},
        { room_feat_custom:       { label: "Custom renovations available", data: 'amenity', group: 'features' }},
        { room_feat_parking:      { label: "Dedicated parking", data: 'amenity', group: 'features' }},
        { room_feat_den:          { label: "Den/extra room", data: 'amenity', group: 'features' }},
        { room_feat_dishwasher:   { label: "Dishwasher", data: 'amenity', group: 'features' }},
        { room_feat_fireplace:    { label: "Fireplace", data: 'amenity', group: 'features' }},
        { room_feat_kitchen:      { label: "Full kitchen", data: 'amenity', group: 'features' }},
        { room_feat_climate:      { label: "Individual climate control", data: 'amenity', group: 'features' }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group: 'features' }},
        { room_feat_pvt_garage:   { label: "Private garage", data: 'amenity', group: 'features' }},
        { room_feat_pvt_outdoor:  { label: "Private outdoor space", data: 'amenity', group: 'features' }},
        { room_feat_walkin:       { label: "Walk-in closet", data: 'amenity', group: 'features' }},
        { room_feat_washer:       { label: "Washer/dryer", data: 'amenity', group: 'features' }},

        { room_layouts:           { label: "Layouts", data: 'listings', special: true, group: 'floorplans' }},
        { room_floorplans:        { label: "Sample Floor Plans", data: 'thumbnails', special: true, tagged_as: 'floorplan', group: 'floorplans' }},
        { room_photos:            { label: "Photos", data: 'thumbnails', special: true, tagged_as: 'room', group: 'floorplans' }},
      ],
    },

    { section: 'pricing',
      label: "Pricing Summary",
      desc: "Pricing can vary greatly depending on the accomodations you choose and the " \
            "level of assistance you require, if any. Contact us to find out more.",
      groups: [
        { onetimefees: { label: "One-Time Fees", }},
        { otherfees: { label: "Other Fees", }},
        { carelevels: { label: "Levels Of Care", }},
        { itemizedcare: { label: "Itemized Care", }},
      ],
      attrs: [
        { base_rent:              { label: "Base Fee", data: 'pricerange' }},
        # { rent_starting_price:    { label: "Base Fee Minimum", data: 'price' }},
        # { rent_maximum_price:     { label: "Base Fee Maximum", data: 'price' }},

        { base_rent_second:       { label: "Second Resident Base Fee", data: 'fee' }},

        { care_cost:              { label: "Care Costs", data: 'pricerange' }},
        # { care_starting_price:    { label: "Care Cost Minimum", data: 'price' }},
        # { care_maximum_price:     { label: "Care Cost Maximum", data: 'price', }},
        { rent_includes_care:     { label: "Base Monthly Fee Includes Care Costs", data: 'flag' }},

        { memory_care_cost:       { label: "Memory Care Costs", data: 'pricerange' }},
        # { care_starting_price:    { label: "Care Cost Minimum", data: 'price' }},
        # { care_maximum_price:     { label: "Care Cost Maximum", data: 'price' }},
        { care_includes_rent:     { label: "Memory Care Costs Include Base Monthly Fee", data: 'flag', }},

        { entrance_fee:           { label: "Entrance/Community Fee", data: 'pricerange' }},
        # { entrance_fee_min:       { label: "Minimum Entrance Fee", data: 'price' }},
        # { entrance_fee_max:       { label: "Maximum Entrance Fee", data: 'price', }},

        { entrance_fee_second:    { label: "Second Resident Entrance Fee", data: 'fee' }},

        { pay_runs_out:           { label: "Policy If Private Pay Runs Out", data: 'select',
                                    values: [
                                      {'-' => 'None'},
                                      {'M' => "Community accepts Medicaid"},
                                      {'F' => "Community foundation supports resident"},
                                      {'L' => "Resident must leave community"},
                                   ]}},

        { public_pricing_notes:   { label: "Additional Pricing Information", data: 'text' }},
        { admin_pricing_notes:    { label: "Admin Pricing Notes", data: 'text', admin_only: true }},

        { waiting_list_fee:       { label: "Waiting List Fee", data: 'fee', group: 'onetimefees' }},
        { reservation_fee:        { label: "Reservation Fee", data: 'fee', group: 'onetimefees' }},
        { application_fee:        { label: "Application Fee", data: 'fee', group: 'onetimefees' }},
        { security_deposit:       { label: "Security Deposit", data: 'fee', group: 'onetimefees' }},
        { administrative_fee:     { label: "Administrative Fee", data: 'fee', group: 'onetimefees' }},
        { pendant_fee:            { label: "Emergency Pendant Fee", data: 'fee', group: 'onetimefees' }},
        { pet_fee:                { label: "Pet Fee", data: 'fee', group: 'onetimefees' }},

        { basic_cable_fee:        { label: "Cable (Basic)", data: 'fee', group: 'otherfees' }},
        { premium_cable_fee:      { label: "Cable (Premium)", data: 'fee', group: 'otherfees' }},
        { internet_fee:           { label: "Internet", data: 'fee', group: 'otherfees' }},
        { broadband_fee:          { label: "Internet (Broadband)", data: 'fee', group: 'otherfees' }},
        { laundry_fee:            { label: "Laundry Services", data: 'fee', group: 'otherfees' }},
        { newspaper_fee:          { label: "Newspaper Deliver", data: 'fee', group: 'otherfees' }},
        { phone_fee:              { label: "Phone (Domestic)", data: 'fee', group: 'otherfees' }},

        { care_level_1:           { label: "Care Level 1", data: 'fee', group: 'carelevels' }},
        { care_level_2:           { label: "Care Level 2", data: 'fee', group: 'carelevels' }},
        { care_level_3:           { label: "Care Level 3", data: 'fee', group: 'carelevels' }},
        { care_level_4:           { label: "Care Level 4", data: 'fee', group: 'carelevels' }},
        { care_level_5:           { label: "Care Level 5", data: 'fee', group: 'carelevels' }},
        { care_explanation:       { label: "Explanation of Care Levels", data: 'text', group: 'carelevels' }},

        { day_care_fee:           { label: "Adult Day Care", data: 'fee', group: 'itemizedcare' }},
        { diabetes_fee:           { label: "Diabetes Support", data: 'fee', group: 'itemizedcare' }},
        { hospice_fee:            { label: "Hospice Care", data: 'fee', group: 'itemizedcare' }},
        { incontinence_fee:       { label: "Incontinence Care", data: 'fee', group: 'itemizedcare' }},
        { med_mgmt_fee:           { label: "Medication Management", data: 'fee', group: 'itemizedcare' }},
        { respite_fee:            { label: "Respite Care", data: 'fee', group: 'itemizedcare' }},
        { rehab_fee:              { label: "Short-Term Rehab", data: 'fee', group: 'itemizedcare' }},
      ],
    },

    { section: 'care',
      label: "Available Care",
      desc: "Here you will find the types of healthcare, assistance and support offered at this community, some of which " \
            "may come with an additional cost.",
      groups: [
        { healthcare: { label: "Healthcare Staff", }},
        { visiting: { label: "Visiting Specialists", }},
        { assistance: { label: "Day-to-Day Assistance", }},
        { special: { label: "Special Care", }},
      ],
      attrs: [
        { staff_doctors:              { label: "Doctors", data: 'count' }},
        { staff_doctors_ft:           { label: "Full-Time Doctors", data: 'count' }},
        { staff_nurses:               { label: "Licensed Nurses", data: 'count' }},
        { staff_nurses_ft:            { label: "Full-time Licensed Nurses", data: 'count' }},
        { staff_socworkers:           { label: "Licensed Social Workers", data: 'count' }},
        { staff_socworkers_ft:        { label: "Full-Time Licensed Social Workers", data: 'count' }},

        { care_ft_doctor:             { label: "Full-time doctor", data: 'flag', group: 'healthcare' }},
        { care_ft_nurse:              { label: "Full-time nurse", data: 'flag', group: 'healthcare' }},
        { care_247_nurse:             { label: "Full-time nurse (24/7)", data: 'flag', group: 'healthcare' }},
        { care_rn:                    { label: "Registered nurse (RN)", data: 'flag', group: 'healthcare' }},
        { care_lpn:                   { label: "Licensed practical nurse (LPN)", data: 'flag', group: 'healthcare' }},
        { care_social_worker:         { label: "Social worker(s)", data: 'flag', group: 'healthcare' }},
        { care_onsite_doctor_visits:  { label: "Doctor visits", data: 'flag', group: 'healthcare' }},
        { care_onsite_nurse_visits:   { label: "Nurse visits", data: 'flag', group: 'healthcare' }},

        { care_onsite_audiologist:    { label: "Audiologist", data: 'flag', group: 'visiting' }},
        { care_onsite_cardiologist:   { label: "Cardiologist", data: 'flag', group: 'visiting' }},
        { care_onsite_dentist:        { label: "Dentist", data: 'flag', group: 'visiting' }},
        { care_onsite_dermatologist:  { label: "Dermatologist", data: 'flag', group: 'visiting' }},
        { care_onsite_dietician:      { label: "Dietician", data: 'flag', group: 'visiting' }},
        { care_onsite_endocronologist: { label: "Endocronologist", data: 'flag', group: 'visiting' }},
        { care_onsite_internist:      { label: "Internist", data: 'flag', group: 'visiting' }},
        { care_onsite_neurologist:    { label: "Neurologist", data: 'flag', group: 'visiting' }},
        { care_onsite_opthamologist:  { label: "Opthamologist", data: 'flag', group: 'visiting' }},
        { care_onsite_optometrist:    { label: "Optometrist", data: 'flag', group: 'visiting' }},
        { care_onsite_orthopedist:    { label: "Orthopedist", data: 'flag', group: 'visiting' }},
        { care_onsite_podiatrist:     { label: "Podiatrist", data: 'flag', group: 'visiting' }},
        { care_onsite_aide:           { label: "Private aide", data: 'flag', group: 'visiting' }},
        { care_onsite_pulmonologist:  { label: "Pulmonologist", data: 'flag', group: 'visiting' }},
        { care_onsite_psychologist:   { label: "Psychologist", data: 'flag', group: 'visiting' }},
        { care_onsite_psychiatrist:   { label: "Psychiatrist", data: 'flag', group: 'visiting' }},
        { care_onsite_urologist:      { label: "Urologist", data: 'flag', group: 'visiting' }},


        { assistance_bathing:     { label: "Bathing assistance",   data: 'amenity', group: 'assistance' }},
        { assistance_dressing:    { label: "Dressing assistance",  data: 'amenity', group: 'assistance' }},
        { assistance_errands:     { label: "Escorts to dinner/errands",   data: 'amenity', group: 'assistance' }},
        { assistance_grooming:    { label: "Grooming assistance",  data: 'amenity', group: 'assistance' }},
        { assistance_medication:  { label: "Medication management", data: 'amenity', group: 'assistance' }},
        { assistance_mobility:    { label: "Mobility assistance",  data: 'amenity', group: 'assistance' }},
        { assistance_toileting:   { label: "Toileting assistance", data: 'amenity', group: 'assistance' }},

        { care_daycare:           { label: "Adult day care", data: 'amenity', group: 'special' }},
        { care_dementia:          { label: "Alzheimer's/dementia care", data: 'amenity', group: 'special' }},
        { care_diabetes:          { label: "Diabetes care", data: 'amenity', group: 'special' }},
        { care_hopspice:          { label: "Hospice care", data: 'amenity', group: 'special' }},
        { care_incontinence:      { label: "Incontinence care", data: 'amenity', group: 'special' }},
        { care_mild_cognitive:    { label: "Mild cognitive impairment care", data: 'amenity', group: 'special' }},
        { care_music_therapy:     { label: "Music therapy", data: 'amenity', group: 'special' }},
        { care_occupational:      { label: "Occupational therapy", data: 'amenity', group: 'special' }},
        { care_parkinsons:        { label: "Parkinson's care", data: 'amenity', group: 'special' }},
        { care_physical:          { label: "Physical therapy", data: 'amenity', group: 'special' }},
        { care_rehabilitation:    { label: "Rehabilitation program", data: 'amenity', group: 'special' }},
        { care_respite:           { label: "Respite care", data: 'amenity', group: 'special' }},
        { care_speech:            { label: "Speech therapy", data: 'amenity', group: 'special' }},
        { care_wellness:          { label: "Wellness program", data: 'amenity', group: 'special' }},
      ],
    },

    { section: 'services',
      label: "Services",
      desc: "Staff and visiting professionals offer a variety of services to make residents lives easier, though some " \
            "may come with an additional cost or be subject to availability.",
      groups: [
        { services: { label: "Available Services", }},
        { transportation: { label: "Parking & Transportation", }},
        { security: { label: "Security", }},
      ],
      attrs: [
        { services_banking:        { label: "Banking services", data: 'amenity', group: 'services' }},
        { services_cable:          { label: "Cable included", data: 'amenity', group: 'services' }},
        { services_concierge:      { label: "Concierge services", data: 'amenity', group: 'services' }},
        { services_domestic_phone: { label: "Domestic phone included", data: 'amenity', group: 'services' }},
        { services_drycleaning:    { label: "Dry-cleaning services", data: 'amenity', group: 'services' }},
        { services_hairdresser:    { label: "Hairdresser/barber", data: 'amenity', group: 'services' }},
        { services_housekeeping:   { label: "Housekeeping", data: 'amenity', group: 'services' }},
        { services_laundry:        { label: "Laundry service", data: 'amenity', group: 'services' }},
        { services_linen:          { label: "Linen service", data: 'amenity', group: 'services' }},
        { services_manicurist:     { label: "Manicurist", data: 'amenity', group: 'services' }},
        { services_massage:        { label: "Massage therapist", data: 'amenity', group: 'services' }},
        { services_newspaper:      { label: "Newspaper delivery", data: 'amenity', group: 'services' }},
        { services_volunteers:     { label: "Outside volunteers", data: 'amenity', group: 'services' }},
        { activity_personal_training: { label: "Personal training", data: 'amenity', group: 'services' }},
        { services_pharmacy:       { label: "Pharmacy services", data: 'amenity', group: 'services' }},
        { services_chaplain:       { label: "Priest/chaplain", data: 'amenity', group: 'services' }},
        { services_catering:       { label: "Private event catering", data: 'amenity', group: 'services' }},
        { services_rabbi:          { label: "Rabbi", data: 'amenity', group: 'services' }},
        { services_wifi:           { label: "WiFi included", data: 'amenity', group: 'services' }},
        { services_wifi_common:    { label: "WiFi in common areas", data: 'amenity', group: 'services' }},

        { services_shuttle_service:     { label: "Car/shuttle service", data: 'amenity', group: 'transportation' }},
        { services_parking:             { label: "Parking available", data: 'amenity', group: 'transportation' }},
        { services_scheduled_transport: { label: "Scheduled transportation", data: 'amenity', group: 'transportation' }},
        { services_transportation:      { label: "Transportation arrangement", data: 'amenity', group: 'transportation' }},
        { services_valet_parking:       { label: "Valet parking", data: 'amenity', group: 'transportation' }},

        { security_electronic_key:           { label: "Electronic key entry system", data: 'flag', group: 'security' }},
        { security_emergency_pendant:        { label: "Emergency alert pendants", data: 'flag', group: 'security' }},
        { security_ft_security:              { label: "Full-time security staff", data: 'flag', group: 'security' }},
        { security_ft_gatedf_community:      { label: "Gated community", data: 'flag', group: 'security' }},
        { security_emergency_call:           { label: "In-room emergency call system", data: 'flag', group: 'security' }},
        { security_night_checks:             { label: "Night checks", data: 'flag', group: 'security' }},
        { security_safety_checks:            { label: "Regular safety checks", data: 'flag', group: 'security' }},
        { security_secure_memory:            { label: "Secure memory unit", data: 'flag', group: 'security' }},
        { security_security_system:          { label: "Security system", data: 'flag', group: 'security' }},
        { security_staff_background_checks:  { label: "Staff background checks", data: 'flag', group: 'security' }},
        { security_video_surveillance:       { label: "Video surveillance", data: 'flag', group: 'security' }},
        { security_visitor_checkins:         { label: "Visitor check-in", data: 'flag', group: 'security' }},
      ],
    },

    { section: 'dining',
      label: "Dining",
      desc: "Here you will find the style of dining offered at the community, as well as the types of diets " \
            "they can accomodate. If you have special restrictions, contact us to find out more.",
      groups: [
        { dining: { label: "Dining Style", }},
        { dietary: { label: "Dietary Accomodations", }},
        { menus: { label: "-Menus", }},
      ],
      attrs: [
        { food_3_meals:           { label: "3 meals daily", data: 'amenity', group: 'dining' }},
        { food_all_day:           { label: "Dining available all day", data: 'amenity', group: 'dining' }},
        { diet_foodie_friendly:   { label: "Gourmet dining", data: 'amenity', group: 'dining' }},
        { food_guest_meals:       { label: "Guest meals", data: 'amenity', group: 'dining' }},
        { food_meal_vouchers:     { label: "Meal plans/vouchers", data: 'amenity', group: 'dining' }},
        { food_restaurant_style:  { label: "Restaurant-style dining", data: 'amenity', group: 'dining' }},
        { food_room_service:      { label: "Room service", data: 'amenity', group: 'dining' }},
        { food_24h_snacks:        { label: "Snacks available all day", data: 'amenity', group: 'dining' }},

        { meal_plan:              { label: "Meal Plan", data: 'string', group: 'dining', }},

        { diet_restricted:        { label: "Restricted diets", data: 'amenity', group: 'dietary' }},
        { diet_gluten_free:       { label: "Gluten-free", data: 'amenity', group: 'dietary' }},
        { diet_kosher_meals:      { label: "Kosher meals", data: 'amenity', group: 'dietary' }},
        { diet_pureed:            { label: "Pureed", data: 'amenity', group: 'dietary' }},
        { diet_vegan:             { label: "Vegan", data: 'amenity', group: 'dietary' }},
        { diet_vegetarian:        { label: "Vegetarian", data: 'amenity', group: 'dietary' }},

        { food_menus:             { label: "Sample Menus", data: 'thumbnails', special: true, tagged_as: 'menu', group: 'menus' }},
      ],
    },

    { section: 'activities',
      label: "Activities",
      desc: "Activity calendars speak volumes about the culture of a community. Learn what " \
            " opportunities there are to socialize, stay fit, be creative, stay engaged, grow " \
            "spiritually, and more.",
      groups: [
        { artistic: {label: "Creative & Artistic", icon: "paint-brush", }},
        { fitness: {label: "Fitness & Exercise", icon: "trophy", }},
        { games: { label: "Games & Trivia", icon: "puzzle-piece",}},
        { learning: { label: "Lifelong Learning", icon: "graduation-cap", }},
        { religious: { label: "Religious & Spiritual", icon: "universal-access", }},
        { social: { label: "Social & Entertainment", icon: "beer", }},
        { trips: { label: "Trips & Outings", icon: "shuttle-van", }},
        { calendars: { label: "-Calendars", }},
      ],
      attrs: [
        { activity_acting:            { label: "Acting/drama", data: 'amenity', group: 'artistic' }},
        { activity_arts:              { label: "Arts & crafts", data: 'amenity', group: 'artistic' }},
        { activity_ceramics:          { label: "Ceramics/clay", data: 'amenity', group: 'artistic' }},
        { activity_chimes:            { label: "Chimes/bell choir", data: 'amenity', group: 'artistic' }},
        { activity_comedy:            { label: "Comedy performance", data: 'amenity', group: 'artistic' }},
        { activity_cooking:           { label: "Cooking/baking", data: 'amenity', group: 'artistic' }},
        { activity_drawing:           { label: "Drawing & coloring", data: 'amenity', group: 'artistic' }},
        { activity_floral:            { label: "Flower arranging", data: 'amenity', group: 'artistic' }},
        { activity_gardening:         { label: "Gardening", data: 'amenity', group: 'artistic' }},
        { activity_knitting:          { label: "Knitting/crocheting", data: 'amenity', group: 'artistic' }},
        { activity_painting:          { label: "Painting", data: 'amenity', group: 'artistic' }},
        { activity_photography:       { label: "Photography", data: 'amenity', group: 'artistic' }},
        { activity_poetry:            { label: "Poetry readings", data: 'amenity', group: 'artistic' }},
        { activity_singing:           { label: "Singing/choir", data: 'amenity', group: 'artistic' }},
        { activity_woodworking:       { label: "Woodworking", data: 'amenity', group: 'artistic' }},

        { activity_aquatics:          { label: "Aquatics/water aerobics", data: 'amenity', group: 'fitness' }},
        { activity_balance:           { label: "Balance/stability", data: 'amenity', group: 'fitness' }},
        { activity_biking:            { label: "Biking", data: 'amenity', group: 'fitness' }},
        { activity_bocce:             { label: "Bocce ball", data: 'amenity', group: 'fitness' }},
        { activity_bowling:           { label: "Bowling", data: 'amenity', group: 'fitness' }},
        { activity_cardio_machines:   { label: "Cardio machines", data: 'amenity', group: 'fitness' }},
        { activity_chair_exercise:    { label: "Chair exercise", data: 'amenity', group: 'fitness' }},
        { activity_dancing:           { label: "Dancing", data: 'amenity', group: 'fitness' }},
        { activity_fitness_classes:   { label: "Fitness classes", data: 'amenity', group: 'fitness' }},
        { activity_golf:              { label: "Golf/putting", data: 'amenity', group: 'fitness' }},
        { activity_hiking:            { label: "Hiking", data: 'amenity', group: 'fitness' }},
        { activity_horseback:         { label: "Horseback riding", data: 'amenity', group: 'fitness' }},
        { activity_lawn_games:        { label: "Lawn games", data: 'amenity', group: 'fitness' }},
        { activity_pickleball:        { label: "Pickleball", data: 'amenity', group: 'fitness' }},
        { activity_pilates:           { label: "Pilates", data: 'amenity', group: 'fitness' }},
        { activity_ping_pong:         { label: "Ping pong", data: 'amenity', group: 'fitness' }},
        { activity_racquet_sports:    { label: "Racquet sports", data: 'amenity', group: 'fitness' }},
        { activity_racquetball:       { label: "Racquetball", data: 'amenity', group: 'fitness' }},
        { activity_shuffleboard:      { label: "Shuffleboard", data: 'amenity', group: 'fitness' }},
        { activity_squash:            { label: "Squash", data: 'amenity', group: 'fitness' }},
        { activity_strength:          { label: "Strength training", data: 'amenity', group: 'fitness' }},
        { activity_stretching:        { label: "Stretching", data: 'amenity', group: 'fitness' }},
        { activity_swimming:          { label: "Swimming", data: 'amenity', group: 'fitness' }},
        { activity_tai_chi:           { label: "Tai chi", data: 'amenity', group: 'fitness' }},
        { activity_tennis:            { label: "Tennis", data: 'amenity', group: 'fitness' }},
        { activity_walking_club:      { label: "Walking club", data: 'amenity', group: 'fitness' }},
        { activity_yoga:              { label: "Yoga", data: 'amenity', group: 'fitness' }},
        { activity_zumba:             { label: "Zumba", data: 'amenity', group: 'fitness' }},

        { activity_billiards:         { label: "Billiards/pool", data: 'amenity', group: 'games' }},
        { activity_bingo:             { label: "Bingo", data: 'amenity', group: 'games' }},
        { activity_blackjack:         { label: "Blackjack", data: 'amenity', group: 'games' }},
        { activity_board_games:       { label: "Board games", data: 'amenity', group: 'games' }},
        { activity_bridge:            { label: "Bridge", data: 'amenity', group: 'games' }},
        { activity_card_games:        { label: "Card games", data: 'amenity', group: 'games' }},
        { activity_dominos:           { label: "Dominos", data: 'amenity', group: 'games' }},
        { activity_mahjong:           { label: "Mahjong", data: 'amenity', group: 'games' }},
        { activity_party_games:       { label: "Party games", data: 'amenity', group: 'games' }},
        { activity_pokeno:            { label: "Pokeno", data: 'amenity', group: 'games' }},
        { activity_poker:             { label: "Poker", data: 'amenity', group: 'games' }},
        { activity_puzzles:           { label: "Puzzles", data: 'amenity', group: 'games' }},
        { activity_rummikub:          { label: "Rummikub", data: 'amenity', group: 'games' }},
        { activity_trivia:            { label: "Trivia/brain games", data: 'amenity', group: 'games' }},
        { activity_video_games:       { label: "Video games", data: 'amenity', group: 'games' }},
        { activity_word_games:        { label: "Word games", data: 'amenity', group: 'games' }},

        { activity_art_classes:             { label: "Art classes", data: 'amenity', group: 'learning' }},
        { activity_book_club:               { label: "Book club/reading group", data: 'amenity', group: 'learning' }},
        { activity_technology_classes:      { label: "Computer classes", data: 'amenity', group: 'learning' }},
        { activity_current_events:          { label: "Current events", data: 'amenity', group: 'learning' }},
        { activity_discussion_groups:       { label: "Discussion groups", data: 'amenity', group: 'learning' }},
        { activity_language_classes:        { label: "Language classes", data: 'amenity', group: 'learning' }},
        { activity_lectures:                { label: "Lectures/classes", data: 'amenity', group: 'learning' }},
        { activity_lending_program:         { label: "Local library lending program", data: 'amenity', group: 'learning' }},
        { activity_music_appreciation:      { label: "Music/art appreciation", data: 'amenity', group: 'learning' }},
        { activity_music_classes:           { label: "Music classes", data: 'amenity', group: 'learning' }},
        { activity_writing_classes:         { label: "Writing classes", data: 'amenity', group: 'learning' }},

        { activity_bible_study:             { label: "Bible fellowship/study", data: 'amenity', group: 'religious' }},
        { activity_catholic_mass:           { label: "Catholic mass/communion", data: 'amenity', group: 'religious' }},
        { activity_christian_services:      { label: "Christian services", data: 'amenity', group: 'religious' }},
        { activity_clergy:                  { label: "Clergy visits", data: 'amenity', group: 'religious' }},
        { activity_episcopal:               { label: "Episcopal services", data: 'amenity', group: 'religious' }},
        { activity_hindu_prayer:            { label: "Hindu prayer", data: 'amenity', group: 'religious' }},
        { activity_meditation:              { label: "Meditation", data: 'amenity', group: 'religious' }},
        { activity_nondenominational:       { label: "Non-denominational faith group", data: 'amenity', group: 'religious' }},
        { activity_nondenominational_svcs:  { label: "Non-denominational services", data: 'amenity', group: 'religious' }},
        { activity_quaker_services:         { label: "Quaker services", data: 'amenity', group: 'religious' }},
        { activity_rabbi_study:             { label: "Rabbi study group", data: 'amenity', group: 'religious' }},
        { activity_rosary_group:            { label: "Rosary group", data: 'amenity', group: 'religious' }},
        { activity_shabbat_services:        { label: "Shabbat services", data: 'amenity', group: 'religious' }},
        { activity_church_bus:              { label: "Transportation to church", data: 'amenity', group: 'religious' }},

        { activity_charity:                 { label: "Charity/outreach", data: 'amenity', group: 'social' }},
        { activity_civic:                   { label: "Civic engagement", data: 'amenity', group: 'social' }},
        { activity_happy_hour:              { label: "Happy/social Hour", data: 'amenity', group: 'social' }},
        { activity_intergenerational:       { label: "Intergenerational activities", data: 'amenity', group: 'social' }},
        { activity_karaoke:                 { label: "Karaoke", data: 'amenity', group: 'social' }},
        { activity_live_music:              { label: "Live music/entertainment", data: 'amenity', group: 'social' }},
        { activity_mens_club:               { label: "Men's club", data: 'amenity', group: 'social' }},
        { activity_movies:                  { label: "Movies", data: 'amenity', group: 'social' }},
        { activity_multicultural:           { label: "Multicultural activities", data: 'amenity', group: 'social' }},
        { activity_pet_visits:              { label: "Pet visits", data: 'amenity', group: 'social' }},
        { activity_vendors:                 { label: "Retail vendor visits", data: 'amenity', group: 'social' }},
        { activity_sharing:                 { label: "Sharing/storytelling", data: 'amenity', group: 'social' }},
        { activity_travel:                  { label: "Travel club", data: 'amenity', group: 'social' }},
        { activity_tea_time:                { label: "Tea/coffee time", data: 'amenity', group: 'social' }},
        { activity_watching_sports:         { label: "Watching sports", data: 'amenity', group: 'social' }},
        { activity_wine_tasting:            { label: "Wine tasting", data: 'amenity', group: 'social' }},

        { activity_casino_trips:            { label: "Casinos", data: 'amenity', group: 'trips' }},
        { activity_city_trips:              { label: "City trips", data: 'amenity', group: 'trips' }},
        { activity_farmers_market:          { label: "Farmer's market", data: 'amenity', group: 'trips' }},
        { activity_historical:              { label: "Historical/tourist attractions", data: 'amenity', group: 'trips' }},
        { activity_mall:                    { label: "Mall trips", data: 'amenity', group: 'trips' }},
        { activity_museums:                 { label: "Museums/art galleries", data: 'amenity', group: 'trips' }},
        { activity_concerts:                { label: "Music performances/concerts", data: 'amenity', group: 'trips' }},
        { activity_nature_trips:            { label: "Nature trips", data: 'amenity', group: 'trips' }},
        { activity_dining_out:              { label: "Restaurants", data: 'amenity', group: 'trips' }},
        { activity_shopping:                { label: "Shopping/errands", data: 'amenity', group: 'trips' }},
        { activity_sporting_events:         { label: "Sporting events", data: 'amenity', group: 'trips' }},
        { activity_theater:                 { label: "Theater/performing arts", data: 'amenity', group: 'trips' }},
        { activity_wineries:                { label: "Wineries", data: 'amenity', group: 'trips' }},

        { activity_calendars:   { label: "Sample Calendars", data: 'thumbnails', special: true, tagged_as: 'calendar', group: 'calendars' }},
      ],
    },

    { section: 'amenities',
      label: "Amenities",
      desc: "Amenities represent the 'bones' of a community: the rooms, facilities, features and infrastructure " \
            "meant to enhance and enrich the lives of its residents.",
      groups: [
        { indoor: { label: "Indoor Amenities", icon: "hotel", }},
        { outdoor: { label: "Outdoor Amenities", icon: "tree-alt", }},
        { fitness: { label: "Fitness Facilities", icon: "dumbbell", }},
      ],
      attrs: [
        { amenity_atm:                 { label: "ATM", data: 'amenity', group: 'indoor' }},
        { amenity_crafts_room:         { label: "Arts & crafts room", data: 'amenity', group: 'indoor' }},
        { amenity_bank:                { label: "Bank", data: 'amenity', group: 'indoor' }},
        { amenity_pub:                 { label: "Bar/pub", data: 'amenity', group: 'indoor' }},
        { amenity_billiards_table:     { label: "Billiards/pool table", data: 'amenity', group: 'indoor' }},
        { amenity_cafe:                { label: "Cafe/bistro", data: 'amenity', group: 'indoor' }},
        { amenity_chapel:              { label: "Chapel/worship space", data: 'amenity', group: 'indoor' }},
        { amenity_playroom:            { label: "Children's playroom", data: 'amenity', group: 'indoor' }},
        { amenity_classroom:           { label: "Classroom/lecture hall", data: 'amenity', group: 'indoor' }},
        { amenity_walkways:            { label: "Climate-controlled walkways", data: 'amenity', group: 'indoor' }},
        { amenity_clubhouse:           { label: "Clubhouse", data: 'amenity', group: 'indoor' }},
        { amenity_common_kitchen:      { label: "Common kitchen", data: 'amenity', group: 'indoor' }},
        { amenity_computer_room:       { label: "Computer room/area", data: 'amenity', group: 'indoor' }},
        { amenity_exam_room:           { label: "Examination room", data: 'amenity', group: 'indoor' }},
        { amenity_fireplace:           { label: "Fireplaces", data: 'amenity', group: 'indoor' }},
        { amenity_game_room:           { label: "Game/card room", data: 'amenity', group: 'indoor' }},
        { amenity_hair_salon:          { label: "Hair salon/barber", data: 'amenity', group: 'indoor' }},
        { amenity_laundry:             { label: "Laundry room", data: 'amenity', group: 'indoor' }},
        { amenity_library:             { label: "Library", data: 'amenity', group: 'indoor' }},
        { amenity_lounge:              { label: "Lounge/community room", data: 'amenity', group: 'indoor' }},
        { amenity_media_room:          { label: "Media/film room", data: 'amenity', group: 'indoor' }},
        { amenity_meditation_room:     { label: "Meditation/prayer room", data: 'amenity', group: 'indoor' }},
        { amenity_theater:             { label: "Movie theater", data: 'amenity', group: 'indoor' }},
        { amenity_music_room:          { label: "Music room/conservatory", data: 'amenity', group: 'indoor' }},
        { amenity_nail_salon:          { label: "Nail salon", data: 'amenity', group: 'indoor' }},
        { amenity_guest_suite:         { label: "Overnight guest suite", data: 'amenity', group: 'indoor' }},
        { amenity_piano:               { label: "Piano", data: 'amenity', group: 'indoor' }},
        { amenity_pharmacy:            { label: "Pharmacy", data: 'amenity', group: 'indoor' }},
        { amenity_private_dining_room: { label: "Private dining room", data: 'amenity', group: 'indoor' }},
        { amenity_private_kitchen:     { label: "Private kitchen", data: 'amenity', group: 'indoor' }},
        { amenity_restaurant:          { label: "Restaurant", data: 'amenity', group: 'indoor' }},
        { amenity_spa:                 { label: "Spa", data: 'amenity', group: 'indoor' }},
        { amenity_stage:               { label: "Stage/theater", data: 'amenity', group: 'indoor' }},
        { amenity_store:               { label: "Store", data: 'amenity', group: 'indoor' }},
        { amenity_sun_room:            { label: "Sun room", data: 'amenity', group: 'indoor' }},
        { amenity_tea_room:            { label: "Tea/coffee room", data: 'amenity', group: 'indoor' }},
        { amenity_vending_machines:    { label: "Vending machines", data: 'amenity', group: 'indoor' }},
        { amenity_wellness_center:     { label: "Wellness center", data: 'amenity', group: 'indoor' }},
        { amenity_woodworking_shop:    { label: "Woodworking shop", data: 'amenity', group: 'indoor' }},

        { amenity_walking_paths:           { label: "Walking paths", data: 'amenity', group: 'outdoor' }},
        { amenity_hiking_trails:           { label: "Hiking trails", data: 'amenity', group: 'outdoor' }},
        { amenity_biking_trails:           { label: "Biking trails", data: 'amenity', group: 'outdoor' }},
        { amenity_courtyard:               { label: "Courtyard", data: 'amenity', group: 'outdoor' }},
        { amenity_fountain:                { label: "Fountain/water feature", data: 'amenity', group: 'outdoor' }},
        { amenity_garden:                  { label: "Garden", data: 'amenity', group: 'outdoor' }},
        { amenity_gazebo:                  { label: "Gazebo", data: 'amenity', group: 'outdoor' }},
        { amenity_greenhouse:              { label: "Greenhouse", data: 'amenity', group: 'outdoor' }},
        { amenity_landscaped:              { label: "Landscaped grounds", data: 'amenity', group: 'outdoor' }},
        { amenity_lawn:                    { label: "Lawn", data: 'amenity', group: 'outdoor' }},
        { amenity_grill:                   { label: "Outdoor grill", data: 'amenity', group: 'outdoor' }},
        { amenity_outdoor_dining:          { label: "Outdoor dining area", data: 'amenity', group: 'outdoor' }},
        { amenity_pond:                    { label: "Pond/lake", data: 'amenity', group: 'outdoor' }},
        { amenity_porch:                   { label: "Porch/patio", data: 'amenity', group: 'outdoor' }},
        { amenity_wooded_area:             { label: "Wooded area", data: 'amenity', group: 'outdoor' }},

        { amenitiy_fitness_equipment_room: { label: "Fitness equipment room", data: 'amenity', group: 'fitness' }},
        { amenitiy_exercise_room:          { label: "Exercise room", data: 'amenity', group: 'fitness' }},
        { amenitiy_fitness_center:         { label: "Fitness center", data: 'amenity', group: 'fitness' }},
        { amenitiy_full_gym:               { label: "Full-sized gym", data: 'amenity', group: 'fitness' }},
        { amenitiy_athletic_club:          { label: "Athletic club", data: 'amenity', group: 'fitness' }},
        { amenitiy_sauna:                  { label: "Sauna", data: 'amenity', group: 'fitness' }},
        { amenitiy_steam_room:             { label: "Steam room", data: 'amenity', group: 'fitness' }},

        { amenity_indoor_pool:           { label: "Indoor pool", data: 'amenity', group: 'fitness' }},
        { amenity_outdoor_pool:          { label: "Outdoor pool", data: 'amenity', group: 'fitness' }},
        { amenity_multiple_pools:        { label: "Multiple pools", data: 'amenity', group: 'fitness' }},
        { amenity_hot_tub:               { label: "Whirlpool/hot tub", data: 'amenity', group: 'fitness' }},

        { amenity_golf_18hole:           { label: "18-hole golf course", data: 'amenity', group: 'fitness' }},
        { amenity_gold_9hole:            { label: "9-hole golf course", data: 'amenity', group: 'fitness' }},
        { amenity_multiple_golf_courses: { label: "Multiple golf courses", data: 'amenity', group: 'fitness' }},
        { amenity_golf_nearby:           { label: "Golf courses nearby", data: 'amenity', group: 'fitness' }},
        { amenity_indoor_driving_range:  { label: "Indoor driving range", data: 'amenity', group: 'fitness' }},
        { amenity_outdoor_driving_range: { label: "Outdoor driving range", data: 'amenity', group: 'fitness' }},
        { amenity_indoor_putting:        { label: "Indoor putting area", data: 'amenity', group: 'fitness' }},
        { amenity_outdoor_putting:       { label: "Outdoor putting area", data: 'amenity', group: 'fitness' }},

        { amenity_pickleball_court:      { label: "Pickleball court", data: 'amenity', group: 'fitness' }},
        { amenity_ping_pong:             { label: "Ping pong table", data: 'amenity', group: 'fitness' }},
        { amenity_racquetball_court:     { label: "Racquet ball court", data: 'amenity', group: 'fitness' }},
        { amenity_squash_court:          { label: "Squash court", data: 'amenity', group: 'fitness' }},
        { amenity_tennis_court:          { label: "Tennis court", data: 'amenity', group: 'fitness' }},

        { amenity_bocce_court:           { label: "Bocce ball court", data: 'amenity', group: 'fitness' }},
        { amenity_bowling_alley:         { label: "Bowling alley", data: 'amenity', group: 'fitness' }},
        { amenity_shuffleboard_court:    { label: "Shuffleboard court", data: 'amenity', group: 'fitness' }},
      ],
    },

    { section: 'governance',
      label: "Community Governance",
      groups: [
        { ownership:  { label: "Ownership", }},
        { council: { label: "Resident Council", }},
      ],
      attrs: [
        { parent_company:                  { label: "Operator", data: 'string', admin_only: true }},

        { ownership_nonprofit_religious:   { label: "Religious Non-Profit", data: 'flag', group: 'ownership' }},
        { ownership_nonprofit_secular:     { label: "Secular Non-Profit", data: 'flag', group: 'ownership' }},
        { ownership_private:               { label: "Privately Held", data: 'flag', group: 'ownership' }},
        { ownership_private_equity:        { label: "Private Equity Backed", data: 'flag', group: 'ownership' }},
        { ownership_reit:                  { label: "REIT", data: 'flag', group: 'ownership' }},
        { ownership_public_company:        { label: "Public Company", data: 'flag', group: 'ownership' }},

        { resident_council_finances:       { label: "Influences budget/financial decisions", data: 'flag', group: 'council' }},
        { resident_council_programming:    { label: "Chooses programming", data: 'flag', group: 'council' }},
        { resident_council_advice:         { label: "Provides advice to management", data: 'flag', group: 'council' }},

        { admin_care_decision_notes:       { label: "Admin Care Decision Notes", data: 'string', admin_only: true }},

        { admin_governance_notes:          { label: "Admin Governance Notes", data: 'text', admin_only: true }},
      ],
    },

    { section: 'values',
      label: "Community Values",
      attrs: [
        { community_values:                { label: "Community Values", data: 'text' }},
      ],
    },

    { section: 'certifications',
      label: "Awards & Certifications",
      attrs: [
        { community_awards:                { label: "Awards & Certifications", data: 'text' }},

      ],
    },

    { section: 'makeup',
      label: "Community Makeup",
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

    { section: 'contracts',
      label: "Contract Options",
      groups: [
        { contract: { label: "Contract Types", }},
        { entrance: { label: "Entrance Fee & Refund", }},
      ],
      attrs: [
        { contract_type_extensive:     { label: "Extensive (Life Care)", data: 'flag', group: 'contract' }},
        { contract_type_modified:      { label: "Modified", data: 'flag', group: 'contract' }},
        { contract_type_fee:           { label: "Fee for Service", data: 'flag', group: 'contract' }},
        { contract_type_rental:        { label: "Rental", data: 'flag', group: 'contract' }},
        { contract_type_equity:        { label: "Equity", data: 'flag', group: 'contract' }},

        { entrance_fee_required:       { label: "Entrance Fee Required", data: 'flag', group: 'entrance' }},
        { refund_option:               { label: "Entrance Fee Refund Option", data: 'flag', group: 'entrance' }},
        { refund_offered:              { label: "Refund Offered", data: 'countrange', group: 'entrance' }},
        # { refund_option_min:           { label: "Minimum Refund Offered", data: 'count', group: 'entrance' }},
        # { refund_option_max:           { label: "Maximum Refund Offered", data: 'count', group: 'entrance' }},
        { refund_conditions:           { label: "Conditions for Refund", data: 'string', group: 'entrance' }},
        { entrance_fee_amort:          { label: "Amortization Details", data: 'text', group: 'entrance' }},
      ],
    },

    { section: 'entrance',
      label: "Entrance Requirements",
      attrs: [
        { requires_age_qual:          { label: "Requires age qualification", data: 'flag' }},
        { age_qual_requirements:      { label: "Age qualification requirements", data: 'string' }},
        { requires_medical_qual:      { label: "Requires medical qualification", data: 'flag' }},
        { medical_qual_requirements:  { label: "Medical qualification requirements", data: 'string' }},
        { requires_insurance:         { label: "Requires insurance", data: 'flag' }},
        { accepts_medicare:           { label: "Accepts Medicare", data: 'flag' }},
        { accepts_medicare_supl:      { label: "Accepts Medicare supplement", data: 'flag' }},
        { accepts_medicaid:           { label: "Accepts Medicaid", data: 'flag' }},
        { accepts_private_ins:        { label: "Accepts private plan insurance", data: 'flag' }},
        { accepts_long_term_ins:      { label: "Accepts long-term care insurance", data: 'flag' }},
        { insurance_requirements:     { label: "Insurance requirements", data: 'string' }},
        { requires_income_qual:       { label: "Requires financial qualification", data: 'flag' }},
        { income_qual_requirements:   { label: "Financial qualification requirements", data: 'string' }},
      ]
    },

  ])

  #================================================================================================
  Listing = self.new([
    { section: 'listing',
      label: "Listing Details",
      groups: [
        { basics: {}},
        { description: {}},
        { pricing: {}},
        { unit: {}},
        { features: {label: "Features"}},
      ],
      attrs: [
        { name:         { label: "Layout Name", data: 'string', direct_model_attribute: true, group: 'basics' }},
        { caption:      { label: "Caption", data: 'string', group: 'basics' }},
        { description:  { label: "Description", data: 'text', group: 'description' }},

        { base_rent:              { label: "Base Fee", data: 'pricerange', group: 'pricing' }},
        { entrance_fee:           { label: "Entrance/Community Fee", data: 'pricerange', group: 'pricing' }},

        { unit_type:    { label: "Unit type", data: 'select', group: 'unit', adminSelectMulti: true,
                          values: [
                            {'room' => "Room"},
                            {'apt' => "Apartment"},
                            {'home' => "Detached Home"},
                        ]}},
        { bedrooms:     { label: "Bedrooms", data: 'select', group: 'unit', adminSelectMulti: true,
                          values: [
                            {'Shared' => "Shared"},
                            {'Studio' => "Studio"},
                            {'1' => "1 Bedroom"},
                            {'2' => "2 Bedrooms"},
                            {'3' => "3 Bedrooms"},
                            {'4+' => "4 or more bedrooms"},
                          ],
                        }},
        { bathrooms:    { label: "Bathrooms", data: 'select', group: 'unit', adminSelectMulti: true,
                          values: [
                            {'1' => "1 Bathroom"},
                            {'1.5' => "1½ Bathrooms"},
                            {'2' => "2 Bathrooms"},
                            {'3+' => "3 or more bathrooms"},
                          ],
                        }},
        { sqft:         { label: "Area (ft²)", data: 'number', group: 'unit', }},

        { room_feat_bathtub:      { label: "Bathtub", data: 'amenity', group: 'features' }},
        { room_feat_custom:       { label: "Custom renovations available", data: 'amenity', group: 'features' }},
        { room_feat_parking:      { label: "Dedicated parking", data: 'amenity', group: 'features' }},
        { room_feat_den:          { label: "Den/extra room", data: 'amenity', group: 'features' }},
        { room_feat_dishwasher:   { label: "Dishwasher", data: 'amenity', group: 'features' }},
        { room_feat_fireplace:    { label: "Fireplace", data: 'amenity', group: 'features' }},
        { room_feat_kitchen:      { label: "Full kitchen", data: 'amenity', group: 'features' }},
        { room_feat_climate:      { label: "Individual climate control", data: 'amenity', group: 'features' }},
        { room_feat_kitchenette:  { label: "Kitchenette", data: 'amenity', group: 'features' }},
        { room_feat_pvt_garage:   { label: "Private garage", data: 'amenity', group: 'features' }},
        { room_feat_pvt_outdoor:  { label: "Private outdoor space", data: 'amenity', group: 'features' }},
        { room_feat_walkin:       { label: "Walk-in closet", data: 'amenity', group: 'features' }},
        { room_feat_washer:       { label: "Washer/dryer", data: 'amenity', group: 'features' }},
      ],
    }
  ])

  #================================================================================================
end
