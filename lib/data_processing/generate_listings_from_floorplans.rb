# run in rails console with
# require 'data_processing/generate_listings_from_floorplans'; GenerateListingsFromFloorplans.process
#

module GenerateListingsFromFloorplans
  def self.process
    to_process = []

    Community.includes(:community_images, :listings).find_each do |community|
      floorplans = community.community_images.select {|i| i.tags =~ /floorplan/}

      to_process << [community, floorplans]
    end

    to_process.each do |community, floorplans|
      puts "#{community.id} #{community.name} - #{floorplans.length} floorplans"

      if floorplans.any?
        puts "   #{floorplans.collect(&:caption).join(", ")}"
        floorplans.each_with_index do |floorplan, index|
          name = floorplan.caption
          name = name.gsub("Floorplan: ", "")
          name = "Layout \##{index}" if name.blank?

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
        end
      end

      data = {}
      data['base_rent'] = community.data['base_rent'] if community.data['base_rent']
      data['entrance_fee'] = community.data['entrance_fee'] if community.data['entrance_fee']

      values = []
      values << 'room' if community.data['room_shared']
      values << 'room' if community.data['room_private']
      values << 'room' if community.data['room_companion']
      values << 'apt' if community.data['room_studio']
      values << 'apt' if community.data['room_one_bed']
      values << 'apt' if community.data['room_two_plus']
      values << 'home' if community.data['room_detached']
      data['unit_type'] = values.uniq.compact.join(",") if values.any?

      values = []
      values << 'Shared' if community.data['room_shared']
      values << '1' if community.data['room_private']
      values << '2' if community.data['room_companion']
      values << 'Studio' if community.data['room_studio']
      values << '1' if community.data['room_one_bed']
      values << '2' if community.data['room_two_plus']
      data['bedrooms'] = values.uniq.compact.join(",") if values.any?

      data['room_feat_bathtub'] = true if community.data['room_feat_bathtub']
      data['room_feat_custom'] = true if community.data['room_feat_custom']
      data['room_feat_parking'] = true if community.data['room_feat_parking']
      data['room_feat_den'] = true if community.data['room_feat_den']
      data['room_feat_dishwasher'] = true if community.data['room_feat_dishwasher']
      data['room_feat_fireplace'] = true if community.data['room_feat_fireplace']
      data['room_feat_kitchen'] = true if community.data['room_feat_kitchen']
      data['room_feat_climate'] = true if community.data['room_feat_climate']
      data['room_feat_kitchenette'] = true if community.data['room_feat_kitchenette']
      data['room_feat_pvt_garage'] = true if community.data['room_feat_pvt_garage']
      data['room_feat_pvt_outdoor'] = true if community.data['room_feat_pvt_outdoor']
      data['room_feat_walkin'] = true if community.data['room_feat_walkin']
      data['room_feat_washer'] = true if community.data['room_feat_washer']

      if data.keys.any?
        listing = community.listings.find_or_create_by(name: "General Layout Information")
        listing.data = data
        listing.is_hidden!
        listing.save
      end

      community.listings.reload
      community.update_reflected_attributes_from_listings

      puts ""
    end
  end
end
