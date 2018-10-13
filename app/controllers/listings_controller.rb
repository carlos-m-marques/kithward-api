require 'tempfile'

class ListingsController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show, :dictionary]

  def index
    @community = Community.find(params[:community_id])

    @listings = @community.listings

    if @community.is_active? or (accessing_account and accessing_account.is_admin?)
      render json: ListingsSerializer.render(@listings.to_a)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def show
    @listing = Listing.find(params[:id])

    if (@listing.is_active? and @community.is_active?) or (accessing_account and accessing_account.is_admin?)

      render json: ListingsSerializer.render(@listing)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    @community = Community.find(params[:community_id])
    @listing = process_one_listing(@community, params)

    if @listing.errors.any?
      render json: { errors: @listing.errors}, status: :unprocessable_entity
    else
      render json: ListingsSerializer.render(@listing)
    end
  end

  def create
    @community = Community.find(params[:community_id])

    @listing = @community.listings.create

    @listing.attributes = params.permit(
      :name, :status, :sort_order
    )

    if params[:data]
      params[:data].permit!
      @listing.data = (@listing.data || {}).merge(params[:data])
    end

    @listing.save

    if @listing.errors.any?
      render json: { errors: @listing.errors}, status: :unprocessable_entity
    else
      render json: ListingsSerializer.render(@listing)
    end
  end

  def dictionary
    render json: DataDictionary::Listing.to_h
  end

  def self.process_one_listing(community, params)
    if params && params[:id] && params[:id].to_i > 0
      listing = community.listings.find_by_id(params[:id])
      listing && listing.update_attributes(params.permit(:name, :status, :sort_order))
    elsif params[:name]
      listing = community.listings.create(params.permit(:name, :status, :sort_order))
    end

    if listing && params[:data]
      params[:data].permit!
      listing.data = (listing.data || {}).merge(params[:data])
      listing.save
    end

    if listing && params[:images]
      params[:images].each {|data| ListingImagesController.process_one_image(listing, data) }
    end

    listing
  end
end
