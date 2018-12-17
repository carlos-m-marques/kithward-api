require 'csv'

class CommunityImporter
  ATTR_ALIASES = {
    'type'      => 'care_type',
    'address'   => 'street',
    'street_address'   => 'street',
    'zip'       => 'postal',
    'zip_code'  => 'postal',
  }

  def initialize(params)
    params = params || {}

    @attrs = []
    @entries = []
    @messages = []

    if params[:entries]
      @attrs = params[:attrs]
      @entries = refetch_community_for_previous_entries(params[:entries])
      @messages = []
    else
      data = params[:data] || ""
      options = {}

      if data =~ /\t/
        options[:col_sep] = "\t"
      end

      begin
        lines = CSV.parse(data, options)


        if lines.length > 0
          @attrs = process_headers(lines[0])
        end

        if lines.length > 1
          rows = process_lines(lines[1..-1], 2) # '2' because line 1 is headers, so line 2 is first entry
          @entries = match_communities(rows)
        else
          @messages << {error: "No data!"}
        end
      rescue CSV::MalformedCSVError => e
        @messages << {error: "Malformed CSV: #{e.message}"}
      rescue StandardError => e
        @messages << {error: "Unexpected error: #{e.class} #{e.message}"}
      end
    end
  end

  def to_h
    hash = {
      attrs: @attrs,
      entries: @entries.collect {|e| e.reject {|k, v| k.to_s == 'community_object'}},
    }
    if @messages.any?
      hash[:messages] = @messages
    end
    hash
  end

  def process_headers(headers)
    headers.each.with_index.collect do |header, index|
      header = header.strip
      attr = header.underscore.gsub(/\s+/, '_')
      attr = (ATTR_ALIASES[attr] || attr)
      {attr: attr, header: header, pos: index, definition: DataDictionary::Community.attributes[attr]}.with_indifferent_access
    end
  end

  def process_lines(lines, starting_line_number = 2)
    lines.each.with_index.collect do |line, index|
      hash = @attrs.collect {|attr| [attr[:attr], (line[attr[:pos]] || "").strip]}.collect {|key, attr| [key, attr.present? ? attr : nil]}.to_h
      hash[:line_number] = starting_line_number + index
      hash.with_indifferent_access
    end
  end

  def refetch_community_for_previous_entries(entries)
    entries.collect do |entry|
      entry = entry.dup
      if entry[:community]
        entry[:community][:id] = entry[:community][:id].to_i
        entry[:community_object] = Community.find(entry[:community][:id])
      end
      entry
    end
  end

  def match_communities(lines)
    lines.collect do |line|
      entry = {data: line}.with_indifferent_access

      if !entry[:data][:kwid] && !(entry[:data][:care_type] && entry[:data][:name] && entry[:data][:postal])
        entry[:messages] ||= []
        entry[:messages] << {error: 'Entries require at least Care Type, Name, and Postal attributes; or a Kithward ID.'}
      else
        entry = match_kwid(entry)

        if !entry[:community]
          entry = match_exact_name(entry)
        end

        if !entry[:community]
          entry = match_simple_name(entry)
        end

        if !entry[:community]
          entry = match_by_geocoding(entry)
        end
      end
      entry
    end
  end

  def match_kwid(entry)
    if entry[:data][:kwid] and entry[:data][:kwid] =~ /^\d+$/
      community = Community.find_by_id(entry[:data][:kwid])
      if community
        if community.is_deleted?
          entry[:messages] ||= []
          entry[:messages] << {error: 'Entry is marked as deleted.'}
        else
          entry[:community] = extract_community_fields(community)
          entry[:community_object] = community
          entry[:match] = 'kwid'
        end
      else
        entry[:messages] ||= []
        entry[:messages] << {error: 'Community not found.'}
      end
    end
    entry
  end

  def match_exact_name(entry)
    matches = Community.where(name: entry[:data][:name], care_type: entry[:data][:care_type], postal: entry[:data][:postal])
    matches = matches.reject {|m| m.is_deleted? }

    if matches.size > 0
      entry[:community] = extract_community_fields(matches[0])
      entry[:community_object] = matches[0]
      entry[:match] = 'name'
      if matches.size > 1
        entry[:additional_matches] = matches[1..-1]
      end
    end

    entry
  end

  def match_simple_name(entry)
    search_options = {
      fields: [{'name' => 'exact'}],
      match: :word_start,
      where: {
        care_type: entry[:data][:care_type],
        postal: entry[:data][:postal]
      },
    }

    name = entry[:data][:name].gsub(/\s+(Assisted|Senior) Living(| Center|Residences|Residence)\s*$/, '')
    name = name.gsub(/^\s*the\s+/, '')
    name = name.gsub(/,\s*the\s*$/, '')
    name = name.gsub(/,*\s*Inc\.*\s*$/, '')

    matches = Community.where(name: name, care_type: entry[:data][:care_type], postal: entry[:data][:postal])

    if matches.size > 0
      entry[:community] = extract_community_fields(matches[0])
      entry[:community_object] = matches[0]
      entry[:match] = 'simplified name'
      if matches.size > 1
        entry[:additional_matches] = matches[1..-1]
      end
    end

    entry
  end

  def match_by_geocoding(entry)
    temp_community = Community.new(street: entry[:data][:street], city: entry[:data][:city], state: entry[:data][:state], postal: entry[:data][:postal], country: entry[:data][:country] || 'USA')
    temp_community.geocode

    if temp_community.lat && temp_community.lon
      search_options = {
        fields: ['name'],
        match: :word_start,
        where: {
          care_type: entry[:data][:care_type],
          postal: entry[:data][:postal],
          location: {near: {lat: temp_community.lat, lon: temp_community.lon}, within: '0.02mi',},
        },
      }

      matches = Community.search('*', search_options)
      matches = matches.reject {|m| m.is_deleted? }

      if matches.size > 0
        entry[:community] = extract_community_fields(matches[0])
        entry[:community_object] = matches[0]
        entry[:match] = 'geocoding'
        entry[:lat] = temp_community.lat
        entry[:lon] = temp_community.lon

        if matches.size > 1
          entry[:additional_matches] = matches[1..-1]
        end
      end
      entry
    end
  end

  def extract_community_fields(c)
    {
      id: c.id, status: c.status, slug: c.slug,
      name: c.name, care_type: c.care_type,
      street: c.street, city: c.city, postal: c.postal,
      lat: c.lat, lon: c.lon,
    }
  end

  def compare
    @entries.each do |entry|
      if entry[:match] == 'kwid' || entry[:match] == 'name' || entry[:data][:process] == 'create'
        if entry[:community_object]
          community = entry[:community_object]
        elsif entry[:community] and entry[:community][:id]
          community = Community.find(entry[:community][:id])
        else
          community = Community.new
          entry[:is_new] = true
        end

        entry[:data].keys.each do |attr|
          value = entry[:data][attr]
          definition = DataDictionary::Community.attributes[attr]

          if definition
            case definition[:data]
            when 'number', 'price', 'count', 'rating'
              value = value.to_i if value.present?
            when 'flag', 'amenity', 'boolean'
              value = value.downcase if value.present?
              value = !!(["1", "yes", "true", "x"].include?(value))
            end

            entry[:data][attr] = value

            if definition[:direct_model_attribute]
              existing_value = community.send(attr)
            else
              existing_value = community.data[attr]
            end

            if existing_value != value
              entry[:diffs] ||= {}
              entry[:diffs][attr] = existing_value
            end
          end
        end
      end
    end
  end

  def import
    @entries.each do |entry|
      attributes = {}
      direct = {}

      if entry[:community_object]
        community = entry[:community_object]
      elsif entry[:community] and entry[:community][:id]
        community = Community.find(entry[:community][:id])
      else
        community = Community.new
        entry[:is_new] = true
        attributes[:needs_review] = true
        attributes[:completeness] = '0'
      end

      entry[:data].keys.each do |attr|
        value = entry[:data][attr]
        definition = DataDictionary::Community.attributes[attr]
        if !entry[:is_new]
          if ['name', 'street', 'city', 'state', 'postal', 'country', 'care_type'].include? attr.to_s
            entry[:messages] ||= []
            entry[:messages] << {warning: "Cannot change '#{attr}' on existing records."}
            next
          end
        end

        if definition
          case definition[:data]
          when 'number', 'price', 'count', 'rating'
            value = value.to_i if value.present?
          when 'flag', 'amenity', 'boolean'
            value = value.downcase if value.present?
            value = !!(["1", "yes", "true"].include?(value))
          end

          entry[:data][attr] = value

          if definition[:direct_model_attribute]
            direct[attr] = value
          else
            attributes[attr] = value
          end
        end
      end

      if entry[:match] == 'kwid' || entry[:match] == 'name' || (entry[:is_new] && entry[:data][:kwid] == 'create')
        if attributes.any?
          community.data = (community.data || {}).merge(attributes)
        end

        if direct.any?
          community.attributes = direct
        end

        if direct.any? || attributes.any?
          community.save
          entry[:community_object] = community
          entry[:saved] = true
        end
      end
    end
  end
end
