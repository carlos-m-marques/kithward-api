require 'csv'

# run in rails console with
# require 'data_processing/geo_places_importer'; GeoPlacesImporter.import
#

module GeoPlacesImporter
  def self.import
    GeoPlace.delete_all

    `curl -o tmp/geonames-us.zip http://download.geonames.org/export/dump/US.zip`
    `unzip tmp/geonames-us.zip -d tmp/geonames-us`

    CSV.foreach(
      "tmp/geonames-us/US.txt",
      col_sep: "\t", quote_char: "‽" # use a random quote char to prevent problems with quotes in TSV files
    ) do |row|
      next unless row && row[7] && row[7][0..2] == 'PPL' # Populated place

      next unless ['NY', 'NJ', 'CT', 'CA'].include?(row[10])

      next unless row[14].to_i >= 100

      place = GeoPlace.find_or_create_by(reference: "geoname-us:#{row[0]}")
      place.geo_type = GeoPlace::TYPE_GEONAME
      place.name = row[1]
      place.state = row[10]
      place.full_name = "#{place.name}, #{place.state}"
      place.lat = row[4].to_f
      place.lon = row[5].to_f
      place.weight = row[14].to_i
      place.save
    end

    `rm -rf tmp/geonames-us tmp/geonames-us.zip`

    `curl -o tmp/geonames-zips-us.zip http://download.geonames.org/export/zip/US.zip`
    `unzip tmp/geonames-zips-us.zip -d tmp/geonames-zips-us`

    CSV.foreach(
      "tmp/geonames-zips-us/US.txt",
      col_sep: "\t", quote_char: "‽" # use a random quote char to prevent problems with quotes in TSV files
    ) do |row|

      next unless ['NY', 'NJ', 'CT', 'CA'].include?(row[4])

      place = GeoPlace.find_or_create_by(reference: "geoname-zip-us:#{row[1]}")
      place.geo_type = GeoPlace::TYPE_POSTAL
      place.name = "#{row[1]}"
      place.state = row[4]
      place.full_name = "#{place.name} - #{row[2]}, #{place.state}"
      place.lat = row[9].to_f
      place.lon = row[10].to_f
      place.save
    end

    `rm -rf tmp/geonames-zips-us tmp/geonames-zips-us.zip`


    place = GeoPlace.find_or_create_by(reference: "geoname-manual:bloomfield-ct")
    place.geo_type = GeoPlace::TYPE_GEONAME
    place.name = "Bloomfield"
    place.state = "CT"
    place.full_name = "Bloomfield, CT"
    place.lat = 41.8316
    place.lon = -72.7249
    place.weight = 0
    place.save


    GeoPlace.reindex
  end
end
