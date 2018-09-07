
class GeoPlacesController < ApplicationController
  def index
    search_options = {
      fields: ['name'],
      match: :word_start,
      order: {weight: :desc},
    }

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    @places = GeoPlace.search(params[:q], search_options)

    render json: GeoPlaceSerializer.new(@places)
  end

  def show
    @place = GeoPlace.find(params[:id])

    render json: GeoPlaceSerializer.new(@place)
  end
end
