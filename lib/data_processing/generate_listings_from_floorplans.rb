# run in rails console with
# require 'data_processing/generate_listings_from_floorplans'; GenerateListingsFromFloorplans.process
#

module GenerateListingsFromFloorplans
  def self.process
    to_process = []

    Community.includes(:community_images, :listings).find_each do |community|
      floorplans = community.community_images.select {|i| i.tags =~ /floorplan/}

      if floorplans.any?
        to_process << [community, floorplans]
      end
    end

    to_process.each do |community, floorplans|
      puts "#{community.id} #{community.name} - #{floorplans.length} floorplans"
      puts "   #{floorplans.collect(&:caption).join(", ")}"
      floorplans.each_with_index do |floorplan, index|
        name = floorplan.caption || "Layout \##{index}"
        name = name.gsub("Floorplan: ", "")

        listing = community.listings.find_or_create_by(name: name)
        if !listing.listing_images.any?
          begin
            new_image = listing.listing_images.create(
              caption: floorplan.caption,
              tags: floorplan.tags,
            )

            ActiveStorage::Downloader.new(floorplan.image).download_blob_to_tempfile do |tempfile|
              new_image.image.attach({
                io: tempfile,
                filename: floorplan.image.blob.filename,
                content_type: floorplan.image.blob.content_type
              })
            end
            new_image.save
          rescue StandardError => e
            puts "Error downloading image: #{e.class} (#{e.message}):\n    " +
              e.backtrace[0..5].join("\n    ") +
              "\n\n"
          end
        end

        listing.save
      end
      puts ""
    end
  end
end
