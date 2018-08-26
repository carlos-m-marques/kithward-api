
class CommunitiesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show, :dictionary]

  def index
    search_options = {
      fields: ['name', 'description'],
      match: :word_start,
      where: {
        status: Community::STATUS_ACTIVE,
      }
    }

    if params[:geo]
      geo = GeoPlace.find_by_id(params[:geo])
      if geo
        search_options[:where][:location] = {near: {lat: geo.lat, lon: geo.lon}}
        if params[:distance]
          search_options[:where][:location][:within] = params[:distance]
        else
          search_options[:where][:location][:within] = "20mi"
        end
      end
    end

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    @communities = Community.search(params[:q] || "*", search_options)

    render json: CommunitySerializer.new(@communities)
  end

  def show
    @community = Community.find(params[:id])

    if @community.is_active? or (accessing_account and accessing_account.is_admin?)
      render json: CommunitySerializer.new(@community)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    @community = Community.find(params[:id])

    @community.update_attributes(params.permit(
      :care_type, :status,
      :name, :description,
      :address, :address_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
    ))

    if @community.errors.any?
      render json: { errors: @community.errors}, status: :unprocessable_entity
    else
      render json: CommunitySerializer.new(@community)
    end
  end

  def dictionary
    render json: DataDictionary::Community.to_h
  end

end
