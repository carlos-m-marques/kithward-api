class CommunityImagesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show]

  def index
    @community = Community.find(params[:community_id])
    @images = @community.community_images

    render json: CommunityImageSerializer.render(@images)
  end

  def show
    @community = Community.find(params[:community_id])
    @image = @community.community_images.find_by_id(params[:id])

    if @image && @image.image
      redirect_to url_for(@image.image)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def create
    @community = Community.find(params[:community_id])
    @image = @community.community_images.create(params.permit(:caption, :tags, :sort_order, :image))

    if @image
      if @image.errors.any?
        render json: { errors: @image.errors}, status: :unprocessable_entity
      else
        render json: CommunityImageSerializer.render(@image)
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    @community = Community.find(params[:community_id])
    @image = @community.community_images.find_by_id(params[:id])

    @image.update_attributes(params.permit(:caption, :tags, :sort_order, :image))

    if @image
      if @image.errors.any?
        render json: { errors: @image.errors}, status: :unprocessable_entity
      else
        render json: CommunityImageSerializer.render(@image)
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end

# NOTES:
#
# This page might come handy when implementing clients to this API
#   https://github.com/rails/rails/issues/32208
