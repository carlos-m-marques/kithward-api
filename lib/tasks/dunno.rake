require 'listing_dictionary'
require 'community_dictionary'
require 'processing'
require 'converter'
require 'scriptster'

desc "Really dunno so far"
task :community_crunch => :environment do
  processing = Processing.new(COMMUNITY)

  processing.crunch

  report = ""
  community = Community.find(3770)
  report << "Community "
  report << "#{community.name} ".red
  report << "mappings.\n\n".purple

  community.data.each do |c_key, c_value|
    report << "\n_________________________________________________\n".green
    cd = processing.compiled_data_from_db
    report << "#{c_key}: ".blue
    report << " #{c_value}\n".red
    report << "\n"

    report << c_key.purple
    report << "\n"

    cd[c_key.to_sym].each do |key, value|
      unless key == :values
        if key == :data_type
          report << "\t#{key}: ".blue
          report << " #{value} ".red
          report << "(#{processing.data_types[value.to_sym]})\n".green
        else
          report << "\t#{key}: ".blue
          report << " #{value}\n".red
        end
      else
        report << "\t#{key}: \n".blue
        value.each do |key_value|
          report << "\t\t#{key_value.keys[0]}: ".blue
          report << " #{key_value.values[0]}\n".red
        end
      end
    end
    report << "\n_________________________________________________\n".green
  end

  puts report
  # processing.report
end

task :dictionary_report => :environment do
  processing = Processing.new(COMMUNITY)
  processing.crunch
  processing.report
end

task :report => :environment do
  processing = Processing.new(COMMUNITY)
  processing.crunch

  dd = processing.compiled_data_from_db.map do |k, v|
    [k, v] if v[:values]
  end.compact.to_h

  values = dd.map do |_, data|
    data[:values].map(&:values).map(&:last)
  end

  ap values
end

task :community_simulation => :environment do
  processing = Processing.new(COMMUNITY)

  processing.crunch

  report = ""
  community = Community.find(3770)
  report << "Community "
  report << "#{community.name} ".red
  report << "mappings.\n\n".purple

  entity = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = '' } } }
  community.data.each do |c_key, c_value|
    cd = processing.compiled_data_from_db

    next unless (
      (cd[c_key.to_sym][:section_label] && !cd[c_key.to_sym][:section_label].is_a?(Array) && cd[c_key.to_sym][:section_label].length > 1) &&
      (cd[c_key.to_sym][:group_name] && !cd[c_key.to_sym][:group_name].is_a?(Array) && cd[c_key.to_sym][:group_name].length > 1) &&
      (cd[c_key.to_sym][:label] && !cd[c_key.to_sym][:label].is_a?(Array) && cd[c_key.to_sym][:label].length > 1)
    )

    entity[cd[c_key.to_sym][:section_label]][cd[c_key.to_sym][:group_name].capitalize][cd[c_key.to_sym][:label]] = c_value
  end
  puts JSON.pretty_generate(entity)
  # puts report
  # processing.report
end

task :listing_simulation => :environment do
  processing = Processing.new(LISTING)

  processing.crunch

  report = ""
  community = Community.find(3770).listings.each do |community|
    report << "#{community.name}".red

    entity = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = '' } } }
    community.data.each do |c_key, c_value|
      cd = processing.compiled_data_from_db

      next unless (
        (cd[c_key.to_sym][:section_label] && !cd[c_key.to_sym][:section_label].is_a?(Array) && cd[c_key.to_sym][:section_label].length > 1) &&
        (cd[c_key.to_sym][:group_name] && !cd[c_key.to_sym][:group_name].is_a?(Array) && cd[c_key.to_sym][:group_name].length > 1) &&
        (cd[c_key.to_sym][:label] && !cd[c_key.to_sym][:label].is_a?(Array) && cd[c_key.to_sym][:label].length > 1)
      )

      entity[cd[c_key.to_sym][:section_label]][cd[c_key.to_sym][:group_name].capitalize][cd[c_key.to_sym][:label]] = c_value
    end
    puts JSON.pretty_generate(entity)
  end
  # puts report
  # processing.report
end

desc "Really dunno so far"
task :listings_crunch => :environment do
  processing = Processing.new(LISTING)

  processing.crunch

  report = ""
  Community.find(3770).listings.to_a[1..-1].each do |listing|
    report << "Listing "
    report << "#{listing.name} ".red
    report << "mappings.\n\n".purple

    listing.data.each do |l_key, l_value|
      report << "\n_________________________________________________\n".green
      cd = processing.compiled_data_from_db
      report << "#{l_key}: ".blue
      report << " #{l_value}\n".red
      report << "\n"

      report << l_key.purple
      report << "\n"

      cd[l_key.to_sym].each do |key, value|
        unless key == :values
          if key == :data_type
            report << "\t#{key}: ".blue
            report << " #{value} ".red
            report << "(#{processing.data_types[value.to_sym]})\n".green
          else
            report << "\t#{key}: ".blue
            report << " #{value}\n".red
          end
        else
          report << "\t#{key}: \n".blue
          value.each do |key_value|
            report << "\t\t#{key_value.keys[0]}: ".blue
            report << " #{key_value.values[0]}\n".red
          end
        end
      end
      report << "\n_________________________________________________\n".green
    end
  end

  puts report
end

desc "Really dunno so far"
task :convert => :environment do
  Scriptster.log :info, 'Starting converter...'
  converter = Converter.new
  converter.convert
end
