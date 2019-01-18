
class PoisController < ApplicationController
  before_action :admin_account_required!, except: [:show]

  def index
    search_options = {
      fields: ['name', 'street'],
      match: :word_start,
      includes: [:poi_category],
    }

    if params[:community]
      community = Community.find(params[:community])

      search_options[:where] = {location: {near: {lat: community.lat, lon: community.lon}}}
    elsif params[:geo]
      geo = GeoPlace.find(params[:geo])

      search_options[:where] = {location: {near: {lat: geo.lat, lon: geo.lon}}}
    end

    if search_options[:where]
      if params[:distance]
        search_options[:where][:location][:within] = params[:distance]
      else
        search_options[:where][:location][:within] = "20mi"
      end
    end

    search_options[:limit] = params[:limit] || 100
    search_options[:offset] = params[:offset] || 0

    pois = Poi.search(params[:q] || "*", search_options).to_a

    render json: PoiSerializer.render(pois)
  end

  def show
    poi = Poi.find(params[:id])

    render json: PoiSerializer.render(poi)
  end

  def search

  end

  def create
    attrs = params.permit(:name, :street, :city, :postal, :state, :country, :poi_category_id).to_h
    attrs[:created_by_id] = accessing_account.id
    attrs[:poi_category_id] ||= params[:poi_category] || params[:category_id] || (params[:category] && params[:category][:id])
    poi = Poi.create(attrs)

    if poi.errors.any?
      render json: { errors: poi.errors}, status: :unprocessable_entity
    else
      render json: PoiSerializer.render(poi)
    end
  end

  def update
    poi = Poi.find(params[:id])

    attrs = params.permit(:name, :street, :city, :postal, :state, :country, :poi_category_id).to_h
    attrs[:poi_category_id] ||= params[:poi_category] || params[:category_id] || (params[:category] && params[:category][:id])
    poi.update_attributes(attrs)

    if poi.errors.any?
      render json: { errors: poi.errors}, status: :unprocessable_entity
    else
      render json: PoiSerializer.render(poi)
    end
  end
end
