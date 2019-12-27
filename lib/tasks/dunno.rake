require 'listing_dictionary'
require 'community_dictionary'
require 'processing'
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
        report << "\t#{key}: ".blue
        report << " #{value}\n".red
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
          report << "\t#{key}: ".blue
          report << " #{value}\n".red
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
