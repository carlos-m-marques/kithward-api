class ListingImagesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show]

  def index
    listing = Listing.find(params[:listing_id])
    images = listing.listing_images

    render json: ListingImageSerializer.render(images)
  end

  def show
    listing = Listing.find(params[:listing_id])
    image = listing.listing_images.find_by_id(params[:id])

    if image && image.image
      redirect_to url_for(image.image)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def create
    listing = Listing.find(params[:listing_id])
    image = listing.listing_images.create(params.permit(:caption, :tags, :sort_order, :image))

    if image
      if image.errors.any?
        render json: { errors: image.errors}, status: :unprocessable_entity
      else
        render json: ListingImageSerializer.render(image)
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    listing = Listing.find(params[:listing_id])
    image = listing.listing_images.find_by_id(params[:id])

    image.update_attributes(params.permit(:caption, :tags, :sort_order, :image))

    if image
      if image.errors.any?
        render json: { errors: image.errors}, status: :unprocessable_entity
      else
        render json: ListingImageSerializer.render(image)
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.process_one_image(listing, params)
    if params && params[:id] && params[:id].to_i > 0
      image = listing.listing_images.find_by_id(params[:id])
      if params[:deleted] == 'deleted'
        image.destroy
      else
        image && image.update_attributes(params.permit(:caption, :tags, :sort_order, :image))
      end
    elsif params && params[:data] && params[:data] =~ /^data:(.*)/
      content_type = params[:data][/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
      content_type = content_type && content_type[/\b(?!.*\/).*/]

      encoded_params = params[:data].gsub(/data:((image|application)\/.{3,}),/, '')
      decoded_params = Base64.decode64(encoded_params).force_encoding("ASCII-8BIT")

      filename = "image_#{Time.now}.#{content_type}"
      tempfile = Tempfile.new(filename, encoding: "ASCII-8BIT")
      tempfile.write(decoded_params)
      tempfile.rewind
      image = listing.listing_images.create(params.permit(:caption, :tags, :sort_order))
      image.image.attach(io: tempfile, filename: filename)
      tempfile.close
      tempfile.unlink
    end
    image
  end

end

# NOTES:
#
# This page might come handy when implementing clients to this API
#   https://github.com/rails/rails/issues/32208
