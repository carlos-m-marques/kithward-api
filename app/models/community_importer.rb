require 'csv'

class CommunityImporter
  ATTR_ALIASES = {
    'type'      => 'care_type',
    'address'   => 'street',
    'street_address'   => 'street',
    'zip'       => 'postal',
    'zip_code'  => 'postal',
  }

  def initialize(csv)
    lines = CSV.parse(csv || "")
    @attrs = []
    @entries = []
    @lines = []
    @errors = []

    if lines.length > 0
      @attrs = process_headers(lines[0])
    end

    if lines.length > 1
      @lines = process_lines(lines[1..-1], 2) # '2' because line 1 is headers, so line 2 is first entry
    else
      @errors << {message: "No data!"}
    end
  end

  def to_h
    hash = {
      attrs: @attrs,
      entries: @lines,
    }
    if @errors.any?
      hash[:errors] = @errors
    end
    hash
  end

  def process_headers(headers)
    headers.each.with_index.collect do |header, index|
      attr = header.underscore.gsub(/\s+/, '_')
      attr = (ATTR_ALIASES[attr] || attr)
      {attr: attr, header: header, pos: index}.with_indifferent_access
    end
  end

  def process_lines(lines, starting_line_number = 2)
    lines.each.with_index.collect do |line, index|
      hash = @attrs.collect {|attr| [attr[:attr], line[attr[:pos]]]}.to_h.with_indifferent_access
      hash[:line_number] = starting_line_number + index
      hash
    end
  end

  def match_communities(lines)
    lines.collect do |line|
      entry = {data: line}

      if !(entry[:data][:care_type] && entry[:data][:name] && entry[:data][:street] && entry[:data][:postal])
        entry[:errors] ||= []
        entry[:errors] << {message: 'Entries require at least Care Type, Name, Street and Postal attributes'}
      else
        entry = match_kwid(entry)

        if !entry.community
          entry = match_exact_name(entry)
        end

        if !entry.community
          entry = match_simplified_name(entry)
        end

        if !entry.community
          entry = match_by_geocoding(entry)
        end
      end
      entry
    end
  end

  def match_kwid(entry)
    if entry[:data][:kwid]
      community = Community.find(entry[:data][:kwid])
      if community.is_deleted?
        entry[:errors] ||= []
        entry[:errors] << {message: 'Entry is marked as deleted'}
      else
        entry[:community] = community
        entry[:match] = 'kwid'
      end
    end
    entry
  end

  def match_exact_name(entry)
    search_options = {
      fields: ['name'],
      match: :word_start,
      where: {
        care_type: entry[:data][:care_type],
        postal: entry[:data][:postal]
      },
    }
    matches = Community.search(entry[:data][:name], search_options)
    matches = matches.reject {|m| m.is_deleted? }

    if matches.size > 0
      entry[:community] = matches[0]
      entry[:match] = 'name'
      if matches.size > 1
        entry[:additional_matches] = matches[1..-1]
      end
    end

    entry
  end

  def match_simple_name(entry)
    search_options = {
      fields: ['name'],
      match: :word_start,
      where: {
        care_type: entry[:data][:care_type],
        postal: entry[:data][:postal]
      },
    }

    name = entry[:data][:name].gsub(/\s+(Assisted|Senior) Living(| Center|Residences|Residence)\s*$/, '')
    matches = Community.search(name, search_options)

    if matches.size > 0
      entry[:community] = matches[0]
      entry[:match] = 'simplified name'
      if matches.size > 1
        entry[:additional_matches] = matches[1..-1]
      end
    end

    entry
  end

  def match_by_geocoding(entry)
    temp_community = Community.new(street: entry[:data][:street], city: entry[:data][:city], state: entry[:data][:state], postal: entry[:data][:postal])
    temp_community.geocode

    if temp_community.lat && temp_community.lon
      search_options = {
        fields: ['name'],
        match: :word_start,
        where: {
          care_type: entry[:data][:care_type],
          postal: entry[:data][:postal],
          location: {near: {lat: temp_community.lat, lon: temp_community.lon}, within: '0.03mi',},
        },
      }

      matches = Community.search('*', search_options)
      matches = matches.reject {|m| m.is_deleted? }

      if matches.size > 0
        entry[:community] = matches[0]
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

end
